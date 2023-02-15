import * as React from 'react';

import { MediaAssetUtilsViewProps } from './MediaAssetUtils.types';

export default function MediaAssetUtilsView(props: MediaAssetUtilsViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
