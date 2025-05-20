import contextConstant from '@ohos.app.ability.contextConstant';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import systemDateTime from '@ohos.systemDateTime';
import fileUri from '@ohos.file.fileuri';
import { FileUtils } from 'core';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import fileIo from '@ohos.file.fs';
import { Context } from '@ohos.arkui.UIContext';
import { promptAction } from '@kit.ArkUI';

export class Utils {
  showMessage(message: string) {
    console.log(message)
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  async saveImageFile(context: Context, fileName: string, resource: Resource) {
    try {
      let path: string = this.getImageCacheFile(context);
      if (!fs.accessSync(path)) {
        fs.mkdirSync(path);
      }
      let completePath = path + '/' + fileName;
      let fd = FileUtils.getInstance().createFile(completePath);
      let aArray = await context.resourceManager.getMediaContent(resource)
      let aBuffer = FileUtils.getInstance().uint8ArrayToBuffer(aArray);
      fs.writeSync(fd, aBuffer);
      fs.closeSync(fd);
    } catch (e) {
      let err = e as BusinessError
    }
  }

  async saveVideoFile(context: Context, fileName: string, resource: Resource) {
    try {
      let path: string = this.getVideoCacheFile(context);
      if (!fs.accessSync(path)) {
        fs.mkdirSync(path);
      }
      let completePath = path + '/' + fileName;
      let fd = FileUtils.getInstance().createFile(completePath);
      let aArray = await context.resourceManager.getMediaContent(resource)
      let aBuffer = FileUtils.getInstance().uint8ArrayToBuffer(aArray);
      fs.writeSync(fd, aBuffer);
      fs.closeSync(fd);
    } catch (e) {
      let err = e as BusinessError
    }
  }

  saveImageByPixelMap(pixelMap: image.PixelMap, context: Context): Promise<string> {
    const imagePackerApi = image.createImagePacker();
    let packOpts: image.PackingOption = { format: "image/jpeg", quality: 98 };
    return imagePackerApi.packing(pixelMap, packOpts)
      .then((data: ArrayBuffer) => {
        // data 为打包获取到的文件流，写入文件保存即可得到一张图片
        try {
          let path: string = this.getImageCacheFile(context);
          if (!fs.accessSync(path)) {
            fs.mkdirSync(path);
          }
          let completePath = path + '/' + 'cover_' + systemDateTime.getTime() + '.jpg'
          let fd = fs.openSync(completePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE).fd;
          fs.writeSync(fd, data);
          fs.closeSync(fd);
          return fileUri.getUriFromPath(completePath)
        } catch (e) {
        }
        return ''
      })
  }

  getImageCacheFile(context: Context) {
    return this.getCacheFile(context, 'image_file');
  }

  getVideoCacheFile(context: Context) {
    return this.getCacheFile(context, 'video_file');
  }

  getCacheFile(context: Context, namespace: string): string {
    let application = context.getApplicationContext();
    if (application.area === contextConstant.AreaMode.EL2) { // 获取area
      application.area = contextConstant.AreaMode.EL1; // 修改area
    }
    let path: string = application.cacheDir + '/' + namespace;
    return path;
  }


  async getPictureUriFromAlbum(context: Context): Promise<string> {
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    let albumPath = photoSelectResult.photoUris[0];

    context = context as common.UIAbilityContext;
    let file: fileIo.File | undefined;
    file = fileIo.openSync(albumPath, fileIo.OpenMode.READ_ONLY);

    let timeStamp = Date.now();
    fileIo.copyFileSync(file.fd, context.filesDir + `/original-${timeStamp}.jpg`);
    fileIo.closeSync(file);

    let filePath = context.filesDir + `/original-${timeStamp}.jpg`;
    return fileUri.getUriFromPath(filePath);
  }

  selectMedia(context: Context, mediaType: string = "image", count?: number): Promise<Array<string>> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
    if (count) {
      photoSelectOptions.maxSelectNumber = count;
    }else if (mediaType === "mix"){
      photoSelectOptions.maxSelectNumber = 9
    }
    if (mediaType === "video") {
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE; // 过滤选择媒体文件类型为IMAGE
    } else if (mediaType === "image") {
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
    } else if (mediaType === "mix") {
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
    }
    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      for (let urisElement of photoSelectResult.photoUris) {
        let file = fileIo.openSync(urisElement, fileIo.OpenMode.READ_ONLY);
        let tempDir = context.getApplicationContext().tempDir;
        let fileName = file.name;
        let tmpFile = tempDir + '/' + fileName;
        fileIo.copyFileSync(file.fd, tmpFile)
        let finalUri = fileUri.getUriFromPath(tmpFile); // 获取到文件的uri
        uris.push(finalUri)
      }
      return uris
    })
  }
}

export default new Utils();