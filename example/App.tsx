import { StyleSheet, Text, View, Button, Image } from "react-native";
import { StatusBar } from "expo-status-bar";
import * as ImagePicker from "expo-image-picker";
import { useEffect, useState } from "react";
import * as MediaLibrary from "expo-media-library";
import * as FileSystem from "expo-file-system";
import * as MediaHelperUtils from "media-asset-utils"

async function getPhotos(setImage) {
  MediaLibrary.getAssetsAsync({
    // createdAfter: new Date(2023, 1, 1),
  }).then(async (assets) => {
    console.log(assets);
    console.log(assets.assets[0].mediaSubtypes);
    setImage(assets.assets[0].uri);

    const assetIds = []
    for (const asset in assets.assets) {
      assetIds.push(assets.assets[asset].id);
      // let info = await MediaLibrary.getAssetInfoAsync(assets.assets[asset].id);
      // console.log(info)
      // if ("11" in info["exif"]["{MakerApple}"]) {
      //   let burstIdentifier = info["exif"]["{MakerApple}"]["11"];
      //   console.log(burstIdentifier);
      //   assetIds.push(burstIdentifier);
      // } else {
      // }
    }

    MediaHelperUtils.exportPhotoAssets(
      assetIds,
      FileSystem.documentDirectory.substring(8)
    ).then((result) => {
      console.log(JSON.stringify(result));
    });
    num += 1;
  });
}

var num = 0;
export default function App() {
  const [image, setImage] = useState(null);
  
  useEffect(() => {
    MediaLibrary.getPermissionsAsync().then((status) => {
      console.log(status);
      if (status.accessPrivileges == "none") {
        MediaLibrary.requestPermissionsAsync().then((status) => {
          console.log(status);
        });
      }
      getPhotos(setImage);
    });

    
  }, []);

  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Image source={{ uri: image }} style={{ width: 500, height: 500 }} />
    </View>
  );
}
