// Import the native module. On web, it will be resolved to MediaAssetUtils.web.ts
// and on native platforms to MediaAssetUtils.ts
import MediaAssetUtilsModule from "./MediaAssetUtilsModule";

export enum PhotoAssetErrors {
  noAssetsFound,
  destinationNotAccessible,
}

export enum PhotoAssetWarnings {
  duplicateIdentifiersRemoved,
  destinationFileAlreadyExists,
  blacklistedExtension,
  noDeletionNecesary,
}

export type ExportedAssetResource = {
  associatedAssetID: string
  localFileLocations: string
  warning: [PhotoAssetWarnings]
}

export type PhotoAssetResults = {
  error?: [PhotoAssetErrors],
  general?: [PhotoAssetWarnings],
  exportResults?: [ExportedAssetResource]
}

export async function exportPhotoAssets(
  photoIdentifiers: [string],
  exportPath: string,
  withPrefix: string = "",
  shouldRemoveExistingFile: boolean = false,
  ignoreBlacklist: boolean = false
): Promise<PhotoAssetResults> {
  return new Promise(async (resolve, reject) => {
    let retStr = await MediaAssetUtilsModule.exportPhotoAssets(
      photoIdentifiers,
      exportPath,
      withPrefix,
      shouldRemoveExistingFile,
      ignoreBlacklist
    );
    resolve(JSON.parse(retStr) as PhotoAssetResults);
  });
}
