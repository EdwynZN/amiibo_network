package com.dartz.amiibo_network;
import android.app.Notification;
import android.app.NotificationChannel;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.FileProvider;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import java.io.File;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.content.Context;
import android.content.ContextWrapper;
import android.annotation.SuppressLint;
import android.os.Build;

import java.io.IOException;
import java.util.Map;
import java.util.List;

public class NotificationUtils extends ContextWrapper {

    private NotificationManagerCompat notificationManager;
    public static final String ANDROID_CHANNEL_ID = "Export";
    public static final String ANDROID_CHANNEL_NAME = "General Notifications";
    private static final String GROUP_ID = "AmiiboNetwork";
    private static final Integer SUMMARY_ID = 0;

    public NotificationUtils(Context base) {
        super(base);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) createChannels();
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    public void createChannels() {
        @SuppressLint("WrongConstant") NotificationChannel notificationChannel =
            new NotificationChannel(ANDROID_CHANNEL_ID, ANDROID_CHANNEL_NAME, NotificationManagerCompat.IMPORTANCE_LOW);
        notificationChannel.setDescription("Screenshots and exporting collections");
        notificationChannel.setShowBadge(false);
        getManager().createNotificationChannel(notificationChannel);
    }

    public void sendNotification(Map<String, Object> arguments) {
        String path = (String) arguments.get("path");
        String title = (String) arguments.get("title");
        String actionTitle = (String) arguments.get("actionTitle");
        Integer id = (Integer) arguments.get("id");

        Notification notification = createNotification(title, path, actionTitle, id);
        getManager().notify(id, notification);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Notification summary = createSummary(title);
            getManager().notify(SUMMARY_ID, summary);
        }
    }

    private Notification createNotification(String title, String path, String actionTitle, Integer id) {
        String text = path.substring(path.lastIndexOf("/")+1);
        File file = new File(path);
        Uri uri = FileProvider.getUriForFile(this, BuildConfig.APPLICATION_ID, file);
        //Log.v("Uri: ", uri.toString());

        NotificationCompat.Builder notificationBuilder =
            new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID);
        notificationBuilder//.setAutoCancel(true)
            .setSmallIcon(R.drawable.ic_notification)
            .setTicker(title)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentTitle(title)
            .setGroup(GROUP_ID)
            .setContentText(text);

        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);

        //Uri imageCollection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);

        sendIntent.setType("text/json");
        Intent chooser = Intent.createChooser(sendIntent, actionTitle);

        List<ResolveInfo> resInfoList = this.getPackageManager().queryIntentActivities(chooser, PackageManager.MATCH_DEFAULT_ONLY);
        for (ResolveInfo resolveInfo : resInfoList) {
            String packageName = resolveInfo.activityInfo.packageName;
            this.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        final int flag =  Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
            ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            : PendingIntent.FLAG_UPDATE_CURRENT;
        PendingIntent pShareIntent = PendingIntent.getActivity(this, id, chooser, flag);

        notificationBuilder//.setContentIntent(pIntent)
            .addAction(android.R.drawable.ic_menu_share, actionTitle, pShareIntent);

        return notificationBuilder.build();
    }

    private Notification imageNotification(String title, String contentText, Uri uri, String actionTitle, Integer id, Bitmap bitmap) {
        NotificationCompat.Builder notificationBuilder =
            new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID);
        notificationBuilder//.setAutoCancel(true)
            .setSmallIcon(R.drawable.ic_notification)
            .setTicker(title)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentTitle(title)
            .setGroup(GROUP_ID)
            .setContentText(contentText);

        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.setDataAndType(uri, "image/png");

        final int flag =  Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
            ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            : PendingIntent.FLAG_UPDATE_CURRENT;
        PendingIntent pContentIntent = PendingIntent.getActivity(this, id, intent, flag);

        sendIntent.setType("image/png");
        Intent chooser = Intent.createChooser(sendIntent, contentText);

        List<ResolveInfo> resInfoList = this.getPackageManager().queryIntentActivities(chooser, PackageManager.MATCH_DEFAULT_ONLY);

        for (ResolveInfo resolveInfo : resInfoList) {
            String packageName = resolveInfo.activityInfo.packageName;
            this.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        PendingIntent pShareIntent = PendingIntent.getActivity(this, id, chooser, flag);


        return notificationBuilder
            .addAction(android.R.drawable.ic_menu_share, actionTitle, pShareIntent)
            .setContentIntent(pContentIntent)
            .setLargeIcon(bitmap)
            .setStyle(new NotificationCompat.BigPictureStyle()
                .bigPicture(bitmap)
                .bigLargeIcon(null)
            )
            .build();
    }

    private Notification createSummary(String title) {
        NotificationCompat.Builder summaryBuilder =
            new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID);
        summaryBuilder.setAutoCancel(true)
            .setSmallIcon(R.drawable.ic_notification)
            .setTicker(title)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentTitle(title)
            .setGroup(GROUP_ID)
            .setGroupSummary(true);
            //.setContentText(text);

        return summaryBuilder.build();
    }

    public void cancelNotification(Integer id) {
        getManager().cancel(id);
    }

    private NotificationManagerCompat getManager() {
        if (notificationManager == null) {
            notificationManager = NotificationManagerCompat.from(this);
        }
        return notificationManager;
    }

    public void showImageNotification(Map<String, Object> arguments) throws IOException{
        String name = (String)arguments.get("name");
        byte[] imageData = (byte[])arguments.get("buffer");
        String title = (String) arguments.get("title");
        String actionTitle = (String) arguments.get("actionTitle");
        Integer id = (Integer) arguments.get("id");
        if(imageData == null) return;
        Bitmap bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length);
        Uri uri;
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) uri = MediaStoreFlutter.updateMediaStore(this, bitmap, name);
        else uri = MediaStoreFlutter.updateLegacyMediaStore(this, bitmap, name);
        Notification notification = imageNotification(title, name + ".png", uri, actionTitle, id, bitmap);
        getManager().notify(id, notification);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Notification summary = createSummary(title);
            getManager().notify(SUMMARY_ID, summary);
        }
    }

}