# media-asset-utils

A helper module to retrieve media library assets

**This is an iOS ONLY package.**

# API documentation

In order to use the library, import the function from the package:

```js
import * as MediaHelperUtils from "media-asset-utils";
```

**Note:** Since the library only exports one function, you can also import it directly. However, there are return types that are extremely useful when parsing the return data in Typescript.

### PhotoAssetErrors 
0 =  noAssetsFound
1 = destinationNotAccessible

### PhotoAssetWarnings 
0 = duplicateIdentifiersRemoved
1 = destinationFileAlreadyExists
2 = blacklistedExtension
3 = noDeletionNecesary

### ExportedAssetResource

associatedAssetID (String): The Asset the resource is associated with

localFileLocations (String): The local file location of the resource

warning ([PhotoAssetWarnings]): An array of warnings that may have occurred during the export process specific to the resource

### PhotoAssetResults

exportResults ([ExportedAssetResource]): An array of exported resources

errors ([PhotoAssetErrors]): An array of errors that may have occurred during the export process

general ([PhotoAssetWarnings]): An array of warnings that may have occurred during the export process in the general process

### exportPhotoAssets

Exports all resources related to each asset in the media library.

This includes, but is not limited to:
- Original File
- Any Paired Videos or Photos (Live Photos)
- Edited Versions of Each Resource by the User
- All images related to the asset if it's a burst photo
- etc

However, extra edited information such as plist files containing user edits are ignored unless specified in parameters.

**Parameters**

photoIdentifiers: [String]

- Accepts a list of photo identifiers that will be used to retrieve the assets from the media library.

to: String

- A specified folder that the assets will be exported to. If folder specified is invalid, the function will return an error.

withPrefix?: String

- A prefix that will be prepended to the exported file name. If no prefix is specified, the file name will be the same as the original file name.

shouldRemoveExistingFile?: Boolean

- A boolean value that determines whether or not the function should remove the existing file if it already exists in the specified folder. If set to false, the function will will NOT overwrite the existing file and provide a warning when attempting to retrieve the resource under the `exportResults` property of the return type.

ignoreBlacklist?: Boolean

- A boolean value that determines whether or not the function should ignore the blacklist of file extensions. If set to true, the function will export all file types regardless of whether or not they are blacklisted. (.plist files are specifically blacklisted by default)

**Returns**

PhotoAssetResults containing all the names and locations of the files exported including any and all errors or warnings that occurred during the process. See data types above for more information.

### Add the package to your npm dependencies

```
npm install media-asset-utils
```

### Configure for iOS

Due to this being a native package, you probably need to run your project using 

```
npx expo run:ios
```

after installing or it may cause JS bundling errors or other weird issues.

# Contributing

Contributions are very welcome! Please make a pull request and I will review it as soon as possible.