package com.dartz.amiibo_network;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.ContextWrapper;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

class MediaStoreFlutter extends ContextWrapper {
    private static final String folder = "Amiibo_Network";

    public MediaStoreFlutter(Context base) {
        super(base);
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    static public Uri updateMediaStore(Context context, Bitmap bitmap, String nameFile) throws IOException {
        ContentResolver resolver = context.getContentResolver();
        Uri imageCollection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
        Uri imageUri = exists(resolver, imageCollection, nameFile);

        ContentValues pictureContent = new ContentValues();
        pictureContent.put(MediaStore.Images.Media.IS_PENDING, 1);
        if(imageUri == null){
            pictureContent.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
            pictureContent.put(MediaStore.Images.Media.DISPLAY_NAME, nameFile + ".png");
            pictureContent.put(MediaStore.Images.Media.TITLE, nameFile);
            pictureContent.put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + File.separator + folder);
            pictureContent.put(MediaStore.Images.Media.OWNER_PACKAGE_NAME, context.getPackageName());
            pictureContent.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
            imageUri = resolver.insert(imageCollection, pictureContent);
        }
        else {
            pictureContent.put(MediaStore.Images.Media.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            resolver.update(imageUri, pictureContent, null, null);
        }

        OutputStream stream = null;

        try {
            //if (imageUri == null) imageUri = resolver.insert(imageCollection, pictureContent);
            if (imageUri == null) throw new IOException("Failed to create/update new MediaStore record.");
            stream = resolver.openOutputStream(imageUri);
            if (stream == null) throw new IOException("Failed to get output stream.");
            if (!bitmap.compress(Bitmap.CompressFormat.PNG, 95, stream)) throw new IOException("Failed to save bitmap.");

            pictureContent.clear();
            pictureContent.put(MediaStore.Images.Media.IS_PENDING, 0);
            resolver.update(imageUri, pictureContent, null, null);
            //Log.v("uri", imageUri.toString());
            //Log.v("Content", imageCollection.toString());
            return imageUri;
        }
        catch (IOException e) {
            // Don't leave an orphan entry in the MediaStore
            if (imageUri != null) resolver.delete(imageUri, null, null);
            throw e;
        }
        finally {
            if (stream != null) stream.close();
        }
    }

    static public Uri updateLegacyMediaStore(Context context, Bitmap bitmap, String nameFile) throws IOException {
        File directory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES + File.separator + folder);
        if(!directory.exists()) directory.mkdirs();

        Uri imageCollection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        ContentResolver resolver = context.getContentResolver();
        Uri imageUri = exists(resolver, imageCollection, nameFile);

        ContentValues pictureContent = new ContentValues();
        if(imageUri == null){
            File file = new File(directory, nameFile + ".png");
            pictureContent.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
            pictureContent.put(MediaStore.Images.Media.DISPLAY_NAME, nameFile + ".png");
            pictureContent.put(MediaStore.Images.Media.TITLE, nameFile);
            pictureContent.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
            pictureContent.put(MediaStore.Images.Media.BUCKET_DISPLAY_NAME, folder);
            pictureContent.put(MediaStore.Images.Media.DATA, file.getAbsolutePath());
            imageUri = resolver.insert(imageCollection, pictureContent);
        }

        try (OutputStream stream = resolver.openOutputStream(imageUri, "w")) {
            if (!bitmap.compress(Bitmap.CompressFormat.PNG, 95, stream)) throw new IOException("Failed to save bitmap.");
            pictureContent.clear();
            pictureContent.put(MediaStore.Images.Media.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            resolver.update(imageUri, pictureContent, null, null);
            return imageUri;
        } catch (IOException e) {
            if (imageUri != null) resolver.delete(imageUri, null, null);
            throw e;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    static public Uri updateDownloadStore(Context context, byte[] data, String nameFile) throws IOException {
        ContentResolver resolver = context.getContentResolver();
        Uri docCollection = MediaStore.Files.getContentUri("external");
        Uri uri = existsFile(resolver, docCollection, nameFile);

        ContentValues content = new ContentValues();
        content.put(MediaStore.Files.FileColumns.IS_PENDING, 1);
        if(uri == null) {
            content.put(MediaStore.Files.FileColumns.MIME_TYPE, "application/json");
            content.put(MediaStore.Files.FileColumns.DISPLAY_NAME, nameFile + ".json");
            content.put(MediaStore.Files.FileColumns.TITLE, nameFile);
            content.put(MediaStore.Files.FileColumns.RELATIVE_PATH, Environment.DIRECTORY_DOCUMENTS);
            content.put(MediaStore.Files.FileColumns.OWNER_PACKAGE_NAME, context.getPackageName());
            content.put(MediaStore.Files.FileColumns.DATE_TAKEN, System.currentTimeMillis());
            uri = resolver.insert(docCollection, content);
        } else {
            content.put(MediaStore.Files.FileColumns.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            resolver.update(uri, content, null, null);
        }

        try (OutputStream stream = resolver.openOutputStream(uri, "w")) {
            stream.write(data, 0, data.length);
            content.clear();
            content.put(MediaStore.Files.FileColumns.IS_PENDING, 0);
            resolver.update(uri, content, null, null);
            //Log.v("uri", uri.toString());
            //Log.v("Content", imageCollection.toString());
            return uri;
        }
        catch (IOException e) {
            // Don't leave an orphan entry in the MediaStore
            if (uri != null) resolver.delete(uri, null, null);
            throw e;
        }
    }

    static public Uri updateLegacyDownloadStore(Context context, byte[] data, String nameFile) throws IOException {
        File directory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS);
        if(!directory.exists()) directory.mkdirs();

        Uri downloadCollection = MediaStore.Files.getContentUri("external");
        ContentResolver resolver = context.getContentResolver();
        Uri uri = existsFile(resolver, downloadCollection, nameFile);

        ContentValues content = new ContentValues();
        if(uri == null) {
            File file = new File(directory, nameFile + ".json");
            content.put(MediaStore.Files.FileColumns.MIME_TYPE, "application/json");
            content.put(MediaStore.Files.FileColumns.DISPLAY_NAME, nameFile + ".json");
            content.put(MediaStore.Files.FileColumns.TITLE, nameFile);
            content.put(MediaStore.Files.FileColumns.DATE_TAKEN, System.currentTimeMillis());
            content.put(MediaStore.Files.FileColumns.BUCKET_DISPLAY_NAME, folder);
            content.put(MediaStore.Files.FileColumns.DATA, file.getAbsolutePath());
            uri = resolver.insert(downloadCollection, content);
        }

        try (OutputStream stream = resolver.openOutputStream(uri, "w")) {
            stream.write(data, 0, data.length);
            content.clear();
            content.put(MediaStore.Files.FileColumns.DATE_MODIFIED, System.currentTimeMillis() / 1000);
            resolver.update(uri, content, null, null);
            return uri;
        } catch (IOException e) {
            if (uri != null) resolver.delete(uri, null, null);
            throw e;
        }
    }

    @Nullable
    static private Uri existsFile(ContentResolver resolver, Uri uri, String nameFile) {
        String selection = MediaStore.Files.FileColumns.MIME_TYPE + " = ? and " + MediaStore.Files.FileColumns.TITLE + " = ?";
        String[] args = new String[] {"application/json", nameFile};

        Cursor cursor = resolver.query(
            uri,
            new String[] {MediaStore.Files.FileColumns.MIME_TYPE, MediaStore.Files.FileColumns.TITLE, MediaStore.Files.FileColumns._ID},
            selection,
            args,
            null
        );
        int id = 0;
        if(cursor != null){
            if(cursor.moveToFirst()) id = cursor.getInt(cursor.getColumnIndex(MediaStore.Files.FileColumns._ID));
            cursor.close();
            if(id != 0) return Uri.withAppendedPath(uri, String.valueOf(id));
        }
        return null;
    }

    @Nullable
    static private Uri existsLegacyFile(ContentResolver resolver, Uri uri, String nameFile) {
        String selection = MediaStore.Files.FileColumns.MIME_TYPE + " = ? and " + MediaStore.Files.FileColumns.TITLE + " = ?";
        String[] args = new String[] {"application/json", nameFile};

        Cursor cursor = resolver.query(
            uri,
            new String[] {MediaStore.Files.FileColumns.MIME_TYPE, MediaStore.Files.FileColumns.TITLE, MediaStore.Files.FileColumns._ID},
            selection,
            args,
            null
        );
        int id = 0;
        if(cursor != null) {
            if(cursor.moveToFirst()) id = cursor.getInt(cursor.getColumnIndex(MediaStore.Files.FileColumns._ID));
            cursor.close();
            if(id != 0) return Uri.withAppendedPath(uri, String.valueOf(id));
        }
        return null;
    }

    @Nullable
    static public Uri exists(ContentResolver resolver, Uri uri, String nameFile) {
        String selection = MediaStore.Images.Media.BUCKET_DISPLAY_NAME + " = ? and " + MediaStore.Images.Media.TITLE + " = ?";
        String[] args = new String[] {folder, nameFile};

        Cursor cursor = resolver.query(uri,
            new String[] {MediaStore.Images.Media.TITLE, MediaStore.Images.Media.BUCKET_DISPLAY_NAME, MediaStore.Images.Media._ID},
            selection, args, null);
        int imageID = 0;
        if(cursor != null){
            if(cursor.moveToFirst()) imageID = cursor.getInt(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
                //Log.v("message: ", Integer.toString(cursor.getCount()));
                //Log.v("message: ", cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)));
                //Log.v("message: ", cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media._ID)));
            cursor.close();
            if(imageID != 0) return Uri.withAppendedPath(uri, String.valueOf(imageID));
        }
        return null;
    }

    @Deprecated
    static public Uri updateLegacyMediaStoreOld(Context context, Bitmap bitmap, String nameFile) throws IOException {
        File directory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES + File.separator + folder);
        if(!directory.exists()) directory.mkdirs();
        File file = new File(directory, nameFile + ".png");

        Uri imageCollection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        ContentResolver resolver = context.getContentResolver();

        Uri imageUri = exists(resolver, imageCollection, nameFile);

        ContentValues pictureContent = new ContentValues();


        /*
        ContentValues pictureContent = new ContentValues();
        pictureContent.put(MediaStore.Images.Media.TITLE, nameFile);
        pictureContent.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
        pictureContent.put(MediaStore.Images.Media.DATA, file.getAbsolutePath());

         */
        //Uri result = null;

        try (FileOutputStream stream = new FileOutputStream(file)) {
            if (!bitmap.compress(Bitmap.CompressFormat.PNG, 95, stream)) throw new IOException("Failed to save bitmap.");
            stream.flush();
            stream.close();
            //stream.getFD().sync();
            /*AtomicReference<Uri> uri = new AtomicReference<>();
            MediaScannerConnection.scanFile(context, new String[]{file.getAbsolutePath()}, null,
                (path, uriContent) -> uri.set(uriContent)
            );*/
            if(imageUri == null){
                pictureContent.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
                pictureContent.put(MediaStore.Images.Media.DISPLAY_NAME, nameFile + ".png");
                pictureContent.put(MediaStore.Images.Media.TITLE, nameFile);
                pictureContent.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
                pictureContent.put(MediaStore.Images.Media.BUCKET_DISPLAY_NAME, folder);
                imageUri = resolver.insert(imageCollection, pictureContent);
            }
            else {
                pictureContent.put(MediaStore.Images.Media.DATE_MODIFIED, System.currentTimeMillis());
                resolver.update(imageUri, pictureContent, null, null);
            }
            //result = exists(resolver, imageCollection, nameFile);
            //if(result == null) result = resolver.insert(imageCollection, pictureContent);
            //if(result != null) Log.v("uri", result.toString());
            return imageUri;
        } catch (IOException e) {
            throw e;
        }
    }

    private void copyFileData(Uri destination, File fileToExport){
        try{
            ParcelFileDescriptor p = this.getContentResolver().openFileDescriptor(destination, "w");
            //OutputStream stream = ParcelFileDescriptor.AutoCloseOutputStream(p);
        }catch (FileNotFoundException e){
            Log.println(Log.ERROR, "tag:", e.toString());
        }
    }

    private void updateMediaExternal(File imageUri) throws IOException {
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return;
        File file = this.getExternalMediaDirs()[0];
        File imageFile = new File(file, Environment.DIRECTORY_PICTURES
                + File.separator + "Image_" + System.currentTimeMillis() + ".png");

        //Uri uri = FileProvider.getUriForFile(this, BuildConfig.APPLICATION_ID, imageFile);

        copy(imageUri, imageFile);
    }

    private static void copy(File src, File dst) throws IOException {
        try (InputStream in = new FileInputStream(src)) {
            try (OutputStream out = new FileOutputStream(dst)) {
                // Transfer bytes from in to out
                byte[] buf = new byte[1024];
                int len;
                while ((len = in.read(buf)) > 0) {
                    out.write(buf, 0, len);
                }
            }
        }
    }

    private void getPathProviderExternalStorageDirectories(String type) {
        final List<String> paths = new ArrayList<>();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            for (File dir : this.getExternalFilesDirs(type)) {
                if (dir != null)  Log.v("message: ", dir.getAbsolutePath());
            }
        } else {
            File dir = this.getExternalFilesDir(type);
            if (dir != null) Log.v("message: ", dir.getAbsolutePath());
        }
    }
}
