package global.ghostatlas.ark.assistant;

import android.Manifest;
import android.app.Activity;
import android.app.role.RoleManager;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.view.Gravity;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import global.ghostatlas.ark.assistant.net.AtlasRuntimeClient;

public final class MainActivity extends Activity implements TextToSpeech.OnInitListener {
    private static final int AUDIO_PERMISSION = 1001;
    private enum SpeechLane { TALK, ACT }

    private TextView transcript;
    private TextView toolMeta;
    private EditText commandInput;
    private EditText payloadInput;
    private EditText constraintsInput;
    private EditText targetNodeInput;
    private Spinner toolSpinner;
    private TextToSpeech tts;
    private SpeechRecognizer recognizer;
    private SpeechLane pendingLane = SpeechLane.TALK;
    private final List<JSONObject> tools = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        tts = new TextToSpeech(this, this);

        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER_HORIZONTAL);
        root.setPadding(40, 40, 40, 60);
        scroll.addView(root);

        TextView title = new TextView(this);
        title.setText("ATLAS / JANUS VIBE");
        title.setTextSize(28f);
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("Ghost Atlas tool fabric → JANUS → execution → ProofGrid → Thoth");
        subtitle.setPadding(0, 8, 0, 20);
        root.addView(subtitle);

        Button assistant = new Button(this);
        assistant.setText("Make Atlas my assistant");
        assistant.setOnClickListener(v -> requestAssistantRole());
        root.addView(assistant);

        Button renderConsole = new Button(this);
        renderConsole.setText("Open live Render console");
        renderConsole.setOnClickListener(v -> startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(AtlasRuntimeClient.renderConsoleUrl()))));
        root.addView(renderConsole);

        TextView toolLabel = new TextView(this);
        toolLabel.setText("GHOST ATLAS TOOL");
        toolLabel.setPadding(0, 22, 0, 6);
        root.addView(toolLabel);

        toolSpinner = new Spinner(this);
        root.addView(toolSpinner);
        toolSpinner.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override public void onItemSelected(android.widget.AdapterView<?> parent, android.view.View view, int position, long id) { showToolMeta(position); }
            @Override public void onNothingSelected(android.widget.AdapterView<?> parent) {}
        });

        toolMeta = new TextView(this);
        toolMeta.setText("Loading live tool registry…");
        toolMeta.setPadding(0, 8, 0, 12);
        root.addView(toolMeta);

        commandInput = new EditText(this);
        commandInput.setHint("Architect command / intent");
        commandInput.setMinLines(2);
        root.addView(commandInput);

        payloadInput = new EditText(this);
        payloadInput.setHint("Tool payload JSON");
        payloadInput.setText("{}");
        payloadInput.setMinLines(3);
        root.addView(payloadInput);

        targetNodeInput = new EditText(this);
        targetNodeInput.setHint("Target node (EDEN for EDEN tools)");
        targetNodeInput.setText("EDEN");
        root.addView(targetNodeInput);

        constraintsInput = new EditText(this);
        constraintsInput.setHint("Constraints JSON");
        constraintsInput.setText("{}");
        constraintsInput.setMinLines(2);
        root.addView(constraintsInput);

        Button voiceAct = new Button(this);
        voiceAct.setText("Speak command");
        voiceAct.setOnClickListener(v -> startListening(SpeechLane.ACT));
        root.addView(voiceAct);

        Button execute = new Button(this);
        execute.setText("Execute selected tool → Proof");
        execute.setOnClickListener(v -> submitAction(commandInput.getText().toString()));
        root.addView(execute);

        Button status = new Button(this);
        status.setText("Estate status · SAMI");
        status.setOnClickListener(v -> loadResidentState());
        root.addView(status);

        Button talk = new Button(this);
        talk.setText("Talk to Atlas · cognition lane");
        talk.setOnClickListener(v -> startListening(SpeechLane.TALK));
        root.addView(talk);

        transcript = new TextView(this);
        transcript.setText("Connecting to Render and loading the live Ghost Atlas tool fabric…");
        transcript.setPadding(0, 24, 0, 24);
        transcript.setTextIsSelectable(true);
        root.addView(transcript);

        setContentView(scroll);
        loadTools();
    }

    private void loadTools() {
        new Thread(() -> {
            try {
                JSONObject response = AtlasRuntimeClient.getTools();
                JSONArray capabilities = response.optJSONArray("capabilities");
                List<String> names = new ArrayList<>();
                tools.clear();
                if (capabilities != null) {
                    for (int i = 0; i < capabilities.length(); i++) {
                        JSONObject tool = capabilities.getJSONObject(i);
                        tools.add(tool);
                        names.add(tool.optString("capability_id", "unknown") + " · " + tool.optString("runtime_location", "runtime"));
                    }
                }
                runOnUiThread(() -> {
                    toolSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, names));
                    transcript.setText("LIVE TOOL FABRIC: " + names.size() + " capabilities loaded from Render.");
                    if (!names.isEmpty()) showToolMeta(0);
                });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("Tool fabric degraded: " + error.getMessage()));
            }
        }, "atlas-tools").start();
    }

    private void showToolMeta(int position) {
        if (position < 0 || position >= tools.size()) return;
        JSONObject tool = tools.get(position);
        toolMeta.setText(
                tool.optString("capability_id", "unknown") + "\n" +
                tool.optString("description", "") + "\nProvider: " + tool.optString("provider", "unknown") +
                " · Executor: " + tool.optString("executor", "unknown") +
                " · Runtime: " + tool.optString("runtime_location", "unknown") +
                "\nInput schema: " + String.valueOf(tool.opt("input_schema")));
    }

    private String selectedCapability() {
        int position = toolSpinner.getSelectedItemPosition();
        return position >= 0 && position < tools.size() ? tools.get(position).optString("capability_id", "") : "";
    }

    private JSONObject parseObject(EditText input, String label) throws Exception {
        String raw = input.getText().toString().trim();
        if (raw.isEmpty()) return new JSONObject();
        try { return new JSONObject(raw); }
        catch (Exception error) { throw new IllegalArgumentException(label + " must be valid JSON"); }
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
            @Override public void onReadyForSpeech(Bundle params) { transcript.setText(pendingLane == SpeechLane.ACT ? "Listening for Ghost Atlas tool command…" : "Listening to Atlas cognition lane…"); }
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
                if (pendingLane == SpeechLane.ACT) {
                    commandInput.setText(speech);
                    submitAction(speech);
                } else submitConversation(speech);
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
                runOnUiThread(() -> transcript.setText(result.toString(2)));
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("SAMI degraded: " + error.getMessage()));
            }
        }, "atlas-status").start();
    }

    private void submitConversation(String speech) {
        transcript.setText("You: " + speech + "\nAtlas cognition lane is separate from tool execution. No action was dispatched.");
        new Thread(() -> {
            try {
                JSONObject brief = AtlasRuntimeClient.getResidentBrief();
                String message = "Atlas heard you. Current resident context is available. Tool execution remains explicit through JANUS.";
                runOnUiThread(() -> { transcript.setText("You: " + speech + "\nAtlas: " + message + "\n\n" + brief); speak(message); });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("Atlas cognition context unavailable: " + error.getMessage()));
            }
        }, "atlas-talk-read-only").start();
    }

    private void submitAction(String speech) {
        String intent = speech == null ? "" : speech.trim();
        String capability = selectedCapability();
        if (intent.isEmpty()) { transcript.setText("Command required."); return; }
        if (capability.isEmpty()) { transcript.setText("Select a Ghost Atlas tool first."); return; }
        transcript.setText("COMMAND: " + intent + "\nTOOL: " + capability + "\nJANUS → Packet/Workforce → execution → proof…");
        new Thread(() -> {
            try {
                JSONObject payload = parseObject(payloadInput, "Payload");
                JSONObject constraints = parseObject(constraintsInput, "Constraints");
                JSONObject response = AtlasRuntimeClient.submitCommand(intent, capability, payload, targetNodeInput.getText().toString(), constraints);
                boolean complete = response.optBoolean("complete", false);
                int proofCount = response.optInt("proof_count", 0);
                String runId = response.optString("run_id", "unknown");
                if (!complete || proofCount < 1) throw new IllegalStateException("Runtime returned without proof-complete state");
                JSONArray proofs = response.optJSONArray("proofs");
                String proofId = proofs != null && proofs.length() > 0 ? proofs.getJSONObject(0).optString("proof_id", "proof-returned") : "proof-returned";
                String spoken = "Complete. " + capability + " executed. Proof received.";
                String rendered = "STATE: COMPLETE\nTOOL: " + capability + "\nRUN: " + runId + "\nPROOF: " + proofId + "\nPROOFS: " + proofCount + "\n\n" + response.toString(2);
                runOnUiThread(() -> { transcript.setText(rendered); speak(spoken); });
            } catch (Exception error) {
                runOnUiThread(() -> transcript.setText("Ghost Atlas command-to-proof failed: " + error.getMessage()));
            }
        }, "atlas-full-tool-command-to-proof").start();
    }

    private void speak(String text) {
        if (tts != null) tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "atlas-response");
    }

    @Override public void onInit(int status) { if (status == TextToSpeech.SUCCESS && tts != null) tts.setLanguage(Locale.US); }
    @Override protected void onDestroy() { if (recognizer != null) recognizer.destroy(); if (tts != null) tts.shutdown(); super.onDestroy(); }
}
