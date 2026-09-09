package global.ghostatlas.ark.assistant;

import android.Manifest;
import android.app.Activity;
import android.app.role.RoleManager;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.provider.Settings;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Locale;

import global.ghostatlas.ark.assistant.net.AtlasRuntimeClient;

public final class MainActivity extends Activity implements TextToSpeech.OnInitListener {
    private static final int AUDIO_PERMISSION = 1001;
    private TextView transcript;
    private TextToSpeech tts;
    private SpeechRecognizer recognizer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        tts = new TextToSpeech(this, this);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        root.setPadding(48, 48, 48, 48);

        TextView title = new TextView(this);
        title.setText("ATLAS / JANUS VIBE");
        title.setTextSize(26f);
        root.addView(title);

        transcript = new TextView(this);
        transcript.setText("Render-connected Android body\nSAMI context • JANUS command boundary • Thoth memory");
        transcript.setPadding(0, 24, 0, 24);
        root.addView(transcript);

        Button assistant = new Button(this);
        assistant.setText("Make Atlas my assistant");
        assistant.setOnClickListener(v -> requestAssistantRole());
        root.addView(assistant);

        Button speak = new Button(this);
        speak.setText("Talk to Atlas");
        speak.setOnClickListener(v -> startListening());
        root.addView(speak);

        Button status = new Button(this);
        status.setText("Estate status");
        status.setOnClickListener(v -> loadResidentState());
        root.addView(status);

        setContentView(root);
    }

    private void requestAssistantRole() {
        RoleManager roleManager = getSystemService(RoleManager.class);
        if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_ASSISTANT)) {
            startActivityForResult(roleManager.createRequestRoleIntent(RoleManager.ROLE_ASSISTANT), 2001);
        } else {
            startActivity(new Intent(Settings.ACTION_VOICE_INPUT_SETTINGS));
        }
    }

    private void startListening() {
        if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, AUDIO_PERMISSION);
            return;
        }
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            transcript.setText("Android speech recognition unavailable on this device.");
            return;
        }
        if (recognizer != null) recognizer.destroy();
        recognizer = SpeechRecognizer.createSpeechRecognizer(this);
        recognizer.setRecognitionListener(new RecognitionListener() {
            @Override public void onReadyForSpeech(Bundle params) { transcript.setText("Listening…"); }
            @Override public void onBeginningOfSpeech() {}
            @Override public void onRmsChanged(float rmsdB) {}
            @Override public void onBufferReceived(byte[] buffer) {}
            @Override public void onEndOfSpeech() {}
            @Override public void onError(int error) { transcript.setText("Speech error: " + error); }
            @Override public void onPartialResults(Bundle partialResults) {}
            @Override public void onEvent(int eventType, Bundle params) {}
            @Override public void onResults(Bundle results) {
                ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (matches != null && !matches.isEmpty()) submit(matches.get(0));
            }
        });
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        recognizer.startListening(intent);
    }

    private void loadResidentState() {
        transcript.setText("Reading SAMI…");
        new Thread(() -> {
            try {
                JSONObject result = AtlasRuntimeClient.getResidentBrief();
                runOnUiThread(() -> transcript.setText(result.toString()));
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("SAMI degraded: " + error.getMessage()));
            }
        }, "atlas-status").start();
    }

    private void submit(String speech) {
        transcript.setText("You: " + speech + "\nRouting through JANUS…");
        new Thread(() -> {
            try {
                JSONObject response = AtlasRuntimeClient.submitCommand(speech);
                String spoken = response.optString("message", response.optString("status", "Command accepted."));
                runOnUiThread(() -> {
                    transcript.setText("You: " + speech + "\nAtlas: " + response.toString());
                    speak(spoken);
                });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("Atlas command degraded: " + error.getMessage()));
            }
        }, "atlas-command").start();
    }

    private void speak(String text) {
        if (tts != null) tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "atlas-response");
    }

    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS && tts != null) tts.setLanguage(Locale.US);
    }

    @Override
    protected void onDestroy() {
        if (recognizer != null) recognizer.destroy();
        if (tts != null) tts.shutdown();
        super.onDestroy();
    }
}
