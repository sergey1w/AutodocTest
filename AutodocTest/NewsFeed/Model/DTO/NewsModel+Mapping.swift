//
//  NewsModel+Mapping.swift
//  AutodocTest
//
//  Created by sergey on 01.02.2025.
//


extension NewsModel: EntityModelMapProtocol {
    
    typealias EntityType = NewsEntity
    
    func mapToEntity(_ managedObject: NewsEntity) {
        managedObject.id = Int64(id)
        managedObject.title = title
        managedObject.subtitle = description
        managedObject.publishedDate = publishedDate
        managedObject.url = url
        managedObject.fullUrl = fullUrl
        managedObject.titleImageUrl = titleImageUrl
        managedObject.categoryType = categoryType
    }
    
    static func mapFromEntity(_ entity: NewsEntity) -> NewsModel {
        return .init(
            id: Int(entity.id),
            title: entity.title!,
            description: entity.subtitle!,
            publishedDate: entity.publishedDate!,
            url: entity.url!,
            fullUrl: entity.fullUrl!,
            titleImageUrl: entity.titleImageUrl,
            categoryType: entity.categoryType!
        )
    }
    
}
