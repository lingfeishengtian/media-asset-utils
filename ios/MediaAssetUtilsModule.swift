import ExpoModulesCore
import Photos

public class MediaAssetUtilsModule: Module {
    // Each module class must implement the definition function. The definition consists of components
    // that describes the module's functionality and behavior.
    // See https://docs.expo.dev/modules/module-api for more details about available components.
    enum PhotoAssetErrors: CustomStringConvertible {
        case noAssetsFound
        case destinationNotAccessible
        
        var description: String {
            switch self {
            case .noAssetsFound:
                return "No assets found for any identifiers"
            case .destinationNotAccessible:
                return "Unable to access specified destination"
            }
        }
    }
    
    enum PhotoAssetWarnings: CustomStringConvertible {
        case duplicateIdentifiersRemoved
        case destinationFileAlreadyExists
        case blacklistedExtension
        
        var description: String {
            switch self {
            case .duplicateIdentifiersRemoved:
                return "All duplicate identifiers removed"
            case .destinationFileAlreadyExists:
                return "Destination file already exists, cannot copy over"
            case .blacklistedExtension:
                return "This extension cannot be exported"
            }
        }
    }
    
    struct ExportedAssetResource {
        var associatedAssetID: String
        var localFileLocations: String
        var warning: [String] = []
        var dict: [String: Any] {
            return [
                "associatedAssetID": associatedAssetID,
                "localFileLocations": localFileLocations,
                "warning": warning
            ]
        }
    }
    
    let BLACKLISTED_EXTENSIONS = ["plist"]
    
        public func definition() -> ModuleDefinition {
            // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
            // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
            // The module will be accessible from `requireNativeModule('LivePhotoUtils')` in JavaScript.
            Name("MediaAssetUtils")
            
            AsyncFunction("exportPhotoAssets") { (withIdentifiers: [String], to: String) -> [String: Any] in
                var returnValue:[String: [Any]] = ["general":[]]
                returnValue["exportResults"] = []
                
                if !FileManager.default.fileExists(atPath: to) || !FileManager.default.isWritableFile(atPath: to) {
                    returnValue["general"]?.append(PhotoAssetErrors.destinationNotAccessible.description)
                }
                
                let identifierSet = Set(withIdentifiers)
                if withIdentifiers.count != withIdentifiers.count {
                    returnValue["general"]?.append(PhotoAssetWarnings.duplicateIdentifiersRemoved.description)
                }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeAllBurstAssets = true
                fetchOptions.includeHiddenAssets = true
                let queriedAssets = PHAsset.fetchAssets(withLocalIdentifiers: Array(identifierSet), options: fetchOptions)
                if queriedAssets.count <= 0{
                    returnValue["general"]?.append(PhotoAssetErrors.noAssetsFound.description)
                }
                // Exported files with nil will be ones that didn't exist in iOS photo library
                
                let options: PHAssetResourceRequestOptions = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true
                
                await withTaskGroup(of: ExportedAssetResource.self, body: {
                    group in
                    var exported = [ExportedAssetResource]()
                    exported.reserveCapacity(queriedAssets.count)
                    
                    let options: PHAssetResourceRequestOptions = PHAssetResourceRequestOptions()
                    options.isNetworkAccessAllowed = true
                    
                    for i in 0..<queriedAssets.count{
                        let queried = queriedAssets.object(at: i)
                        var assetResources: [PHAssetResource] = []
                        if let burstId = queried.burstIdentifier {
                            print(burstId)
                            let queriedBurstAssets = PHAsset.fetchAssets(withBurstIdentifier: burstId, options: fetchOptions)
                            queriedBurstAssets.enumerateObjects({
                                (burstAsset, ind, stop) -> Void in
                                assetResources.append(contentsOf: PHAssetResource.assetResources(for: burstAsset))
                            })
                        } else {
                            assetResources = PHAssetResource.assetResources(for: queried)
                        }
//                        let assetResources = PHAssetResource.assetResources(for: queried)
                        
                        for asset in assetResources {
                            print(asset.originalFilename)
                            let fileExtension: String = URL(fileURLWithPath: asset.originalFilename).pathExtension
                            if !BLACKLISTED_EXTENSIONS.contains(fileExtension.lowercased()) {
                                group.addTask {
                                    let destination = URL(fileURLWithPath: to + "/" + asset.originalFilename).deletingPathExtension().appendingPathExtension(fileExtension)
                                    var newAssetResource = ExportedAssetResource(associatedAssetID: asset.assetLocalIdentifier, localFileLocations: destination.absoluteString)
                                    do {
                                        try await PHAssetResourceManager.default().writeData(for: asset, toFile: destination, options: options)
                                    } catch {
                                        newAssetResource.warning.append(PhotoAssetWarnings.destinationFileAlreadyExists.description)
                                    }
                                    return newAssetResource
                                }
                            }
                        }
                    }
                    
                    for await resource in group {
                        returnValue["exportResults"]?.append(resource.dict)
                    }
                })
                
                return returnValue
            }
        
        // Generic function where an identifier can be used to export all assets to a temporary location
        // TODO: Remove asset resource limit restriction to allow for n amount of resources to be exported.
        AsyncFunction("writeLivePhotoVideoData") { (livePhotoId: String, to: String) -> [String:String] in
            let returnedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [livePhotoId], options: nil)
            print(livePhotoId)
            if returnedAssets.count > 1 {
                return [ "Status": "Too many assets given, invalid identifier" ]
            } else if returnedAssets.count < 1 {
                return [ "Status": "Too few assets given, this is not a live photo" ]
            } else {
                // DOESNT SUPPORT EDITED LIVE PHOTOS
                let assetResources = PHAssetResource.assetResources(for: returnedAssets.object(at: 0))
                
                if assetResources.count > 2 {
                    return [ "Status": "Too many assets resources found, is this a burst image or edited photo?" ]
                } else if assetResources.count < 2 {
                    return [ "Status": "Too few assets resources found, this is not a live photo" ]
                }
                
                for asset in assetResources {
                    print(asset.originalFilename)
                    let options: PHAssetResourceRequestOptions = PHAssetResourceRequestOptions()
                    options.isNetworkAccessAllowed = true
                    let fileExtension: String = URL(fileURLWithPath: asset.originalFilename).pathExtension
                    do {
                        try await PHAssetResourceManager.default().writeData(for: asset, toFile: URL(fileURLWithPath: to).appendingPathExtension(fileExtension), options: options)
                    } catch {
                        // PHPhotosErrorDomain means file exists
                        return ["Status": error.localizedDescription]
                    }
                }
            }
            return ["Status": "exported two files"]
        }
    }
}
