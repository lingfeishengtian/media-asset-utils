// Import the native module. On web, it will be resolved to MediaAssetUtils.web.ts
// and on native platforms to MediaAssetUtils.ts
import MediaAssetUtilsModule from './MediaAssetUtilsModule';

export async function writeLivePhotoVideoData(livePhotoId: string, videoData: string): Promise<{ [key: string]: string; }> {
  return MediaAssetUtilsModule.writeLivePhotoVideoData(livePhotoId, videoData);
}

export async function exportPhotoAssets(photoIdentifiers: [string], exportPath: string): Promise<{ [key: string]: any; }> {
  return MediaAssetUtilsModule.exportPhotoAssets(photoIdentifiers, exportPath);
}