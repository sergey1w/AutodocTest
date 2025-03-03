//
//  CoreDataNewsStorage.swift
//  AutodocNews
//
//  Created by sergey on 26.01.2025.
//

import CoreData
import OSLog

final class CoreDataNewsStorage: NewsFeedStorageProtocol {
    
    let logger = Logger(subsystem: "sergey1w.AutodocTest", category: "persistence")
    
    // MARK: Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "News")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // This sample refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    private var notificationToken: NSObjectProtocol?
    
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    init() {
        
        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: nil
        ) { [logger] _ in
            logger.debug("Received a persistent store remote change notification.")
            Task { [unowned self] in
                await self.fetchPersistentHistory()
            }
        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("Deinited \(String(describing: self))")
    }
    
    var totalCount: Int {
        get async {
            let fetchRequest = NewsEntity.fetchRequest()
            fetchRequest.includesSubentities = false
            fetchRequest.includesPendingChanges = false
            fetchRequest.includesPropertyValues = false
            do {
                return try await persistentContainer.viewContext.perform { [unowned self] in
                    try persistentContainer.viewContext.count(for: fetchRequest)
                }
            } catch {
                return 0
            }
        }
    }
    
    func getNews(page: Int, count: Int) async throws -> [NewsModel] {
        let fetchOffset = (page - 1) * count
        let fetchRequest = self.newFetchRequest(fetchOffset: fetchOffset, fetchLimit: count)
        let viewContext = persistentContainer.viewContext
        
        return try await viewContext.perform { [unowned viewContext, unowned fetchRequest] in
            let fetchResult = try viewContext.fetch(fetchRequest)
            if fetchResult.isEmpty {
                throw NewsError.missingData
            }
            
            return fetchResult.map(NewsModel.mapFromEntity(_:))
        }
    }
    
    func saveNews(news: [NewsModel]) async throws {
        logger.debug("Start importing data to the store...")
        try await importNews(news: news)
        logger.debug("Finished importing data.")
    }
}

extension CoreDataNewsStorage {
    // MARK: Source:
    /// https://developer.apple.com/documentation/swiftui/loading_and_displaying_a_large_data_feed
    
    private func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            logger.debug("\(error.localizedDescription)")
        }
    }
    
    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        logger.debug("Start fetching persistent history changes from the store...")
        
        try await taskContext.perform { [unowned self] in
            // Execute the persistent history change since the last transaction.
            /// - Tag: fetchHistory
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }
            
            self.logger.debug("No persistent history transactions found.")
            throw NewsError.persistentHistoryChangeError
        }
        
        logger.debug("Finished merging history changes.")
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        self.logger.debug("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = persistentContainer.viewContext
        viewContext.perform { [unowned self] in
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        taskContext.undoManager = nil
        return taskContext
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import News into the Core Data store on a private queue.
    private func importNews(news: [NewsModel]) async throws {
        guard !news.isEmpty else { return }
        
        let taskContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNews"
        
        /// - Tag: performAndWait
        try await taskContext.perform { [unowned self] in
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: news)
            guard let fetchResult = try? taskContext.execute(batchInsertRequest),
                  let batchInsertResult = fetchResult as? NSBatchInsertResult,
                  let success = batchInsertResult.result as? Bool, success
            else {
                self.logger.debug("Failed to execute batch insert request.")
                throw NewsError.batchInsertError
            }
            
            logger.debug("Successfully inserted data.")
        }
    }
    
    private func newBatchInsertRequest(with news: [NewsModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = news.count

        let batchInsertRequest = NSBatchInsertRequest(entity: NewsEntity.entity(),
                                                      managedObjectHandler: { managedObject in
            guard index < total else { return true }
            guard let newsEntity = managedObject as? NewsEntity else {
                return false
            }
            
            let data = news[index]
            data.mapToEntity(newsEntity)
            
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    private func newFetchRequest(fetchOffset: Int, fetchLimit: Int) -> NSFetchRequest<NewsEntity> {
        let fetchRequest = NewsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [.init(keyPath: \NewsEntity.id, ascending: false)]
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.includesSubentities = false
        fetchRequest.includesPendingChanges = false
        fetchRequest.resultType = .managedObjectResultType
        return fetchRequest
    }
}
