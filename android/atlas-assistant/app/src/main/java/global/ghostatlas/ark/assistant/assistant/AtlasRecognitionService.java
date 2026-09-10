package global.ghostatlas.ark.assistant.assistant;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.RecognitionService;
import android.speech.SpeechRecognizer;

import java.util.List;

public final class AtlasRecognitionService extends RecognitionService {
    private final Handler main = new Handler(Looper.getMainLooper());
    private SpeechRecognizer delegate;

    @Override
    protected void onStartListening(Intent recognizerIntent, Callback callback) {
        main.post(() -> startDelegate(recognizerIntent, callback));
    }

    @Override
    protected void onStopListening(Callback callback) {
        main.post(() -> {
            if (delegate != null) delegate.stopListening();
        });
    }

    @Override
    protected void onCancel(Callback callback) {
        main.post(() -> cleanup());
    }

    private void startDelegate(Intent recognizerIntent, Callback callback) {
        try {
            cleanup();
            ComponentName external = findExternalRecognizer();
            if (external == null) {
                callback.error(SpeechRecognizer.ERROR_CLIENT);
                return;
            }
            delegate = SpeechRecognizer.createSpeechRecognizer(this, external);
            delegate.setRecognitionListener(new RecognitionListener() {
                @Override public void onReadyForSpeech(Bundle params) { callback.readyForSpeech(params); }
                @Override public void onBeginningOfSpeech() { callback.beginningOfSpeech(); }
                @Override public void onRmsChanged(float rmsdB) { callback.rmsChanged(rmsdB); }
                @Override public void onBufferReceived(byte[] buffer) { callback.bufferReceived(buffer); }
                @Override public void onEndOfSpeech() { callback.endOfSpeech(); }
                @Override public void onError(int error) { callback.error(error); cleanup(); }
                @Override public void onResults(Bundle results) { callback.results(results); cleanup(); }
                @Override public void onPartialResults(Bundle partialResults) { callback.partialResults(partialResults); }
                @Override public void onEvent(int eventType, Bundle params) { }
            });
            delegate.startListening(recognizerIntent);
        } catch (Exception error) {
            callback.error(SpeechRecognizer.ERROR_CLIENT);
            cleanup();
        }
    }

    private ComponentName findExternalRecognizer() {
        Intent query = new Intent(RecognitionService.SERVICE_INTERFACE);
        List<ResolveInfo> services = getPackageManager().queryIntentServices(query, 0);
        for (ResolveInfo info : services) {
            if (info.serviceInfo == null) continue;
            if (getPackageName().equals(info.serviceInfo.packageName)) continue;
            return new ComponentName(info.serviceInfo.packageName, info.serviceInfo.name);
        }
        return null;
    }

    private void cleanup() {
        if (delegate != null) {
            try { delegate.cancel(); } catch (Exception ignored) {}
            delegate.destroy();
            delegate = null;
        }
    }

    @Override
    public void onDestroy() {
        main.post(this::cleanup);
        super.onDestroy();
    }
}
