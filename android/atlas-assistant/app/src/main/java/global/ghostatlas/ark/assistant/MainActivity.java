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

    private enum SpeechLane { TALK, ACT }

    private TextView transcript;
    private TextToSpeech tts;
    private SpeechRecognizer recognizer;
    private SpeechLane pendingLane = SpeechLane.TALK;

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
        transcript.setText(
                "Render-connected Android body\n" +
                "TALK = cognition only • ACT = JANUS-governed execution • STATUS = SAMI");
        transcript.setPadding(0, 24, 0, 24);
        root.addView(transcript);

        Button assistant = new Button(this);
        assistant.setText("Make Atlas my assistant");
        assistant.setOnClickListener(v -> requestAssistantRole());
        root.addView(assistant);

        Button talk = new Button(this);
        talk.setText("Talk to Atlas");
        talk.setOnClickListener(v -> startListening(SpeechLane.TALK));
        root.addView(talk);

        Button act = new Button(this);
        act.setText("Act through JANUS");
        act.setOnClickListener(v -> startListening(SpeechLane.ACT));
        root.addView(act);

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

    private void startListening(SpeechLane lane) {
        pendingLane = lane;
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
            @Override public void onReadyForSpeech(Bundle params) {
                transcript.setText(pendingLane == SpeechLane.ACT ? "Listening for JANUS action…" : "Listening to Atlas conversation…");
            }
            @Override public void onBeginningOfSpeech() {}
            @Override public void onRmsChanged(float rmsdB) {}
            @Override public void onBufferReceived(byte[] buffer) {}
            @Override public void onEndOfSpeech() {}
            @Override public void onError(int error) { transcript.setText("Speech error: " + error); }
            @Override public void onPartialResults(Bundle partialResults) {}
            @Override public void onEvent(int eventType, Bundle params) {}
            @Override public void onResults(Bundle results) {
                ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (matches == null || matches.isEmpty()) return;
                String speech = matches.get(0);
                if (pendingLane == SpeechLane.ACT) submitAction(speech);
                else submitConversation(speech);
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

    private void submitConversation(String speech) {
        transcript.setText("You: " + speech + "\nAtlas: conversation bridge awaiting Render-side binding. No action was dispatched.");
        new Thread(() -> {
            try {
                JSONObject brief = AtlasRuntimeClient.getResidentBrief();
                String context = brief.optJSONObject("counts") != null
                        ? brief.optJSONObject("counts").toString()
                        : "resident state online";
                String message = "Atlas heard you. Conversational inference is not yet bound to the APK. " +
                        "No command was executed. Current resident context: " + context;
                runOnUiThread(() -> {
                    transcript.setText("You: " + speech + "\nAtlas: " + message);
                    speak(message);
                });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText(
                        "You: " + speech + "\nAtlas conversation unavailable; no command was executed. " + error.getMessage()));
            }
        }, "atlas-talk-read-only").start();
    }

    private void submitAction(String speech) {
        transcript.setText("Action request: " + speech + "\nRouting through JANUS…");
        new Thread(() -> {
            try {
                JSONObject response = AtlasRuntimeClient.submitCommand(speech);
                String spoken = response.optString("message", response.optString("status", "Action accepted for governed execution."));
                runOnUiThread(() -> {
                    transcript.setText("Action request: " + speech + "\nJANUS: " + response.toString());
                    speak(spoken);
                });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("JANUS action degraded: " + error.getMessage()));
            }
        }, "atlas-janus-action").start();
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
