import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { MediaAssetUtilsViewProps } from './MediaAssetUtils.types';

const NativeView: React.ComponentType<MediaAssetUtilsViewProps> =
  requireNativeViewManager('MediaAssetUtils');

export default function MediaAssetUtilsView(props: MediaAssetUtilsViewProps) {
  return <NativeView {...props} />;
}
