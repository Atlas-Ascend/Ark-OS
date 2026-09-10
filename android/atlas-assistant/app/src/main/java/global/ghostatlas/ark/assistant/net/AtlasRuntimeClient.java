package global.ghostatlas.ark.assistant.net;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.stream.Collectors;

import global.ghostatlas.ark.assistant.BuildConfig;

public final class AtlasRuntimeClient {
    private AtlasRuntimeClient() {}

    public static JSONObject getResidentBrief() throws Exception {
        return request("GET", "/v1/sami/brief", null, 20_000);
    }

    public static JSONObject getTools() throws Exception {
        return request("GET", "/v1/assistant/tools", null, 20_000);
    }

    public static JSONObject submitCommand(
            String intent,
            String capability,
            JSONObject payload,
            String targetNode,
            JSONObject constraints) throws Exception {
        JSONObject body = new JSONObject();
        body.put("intent", intent);
        body.put("correlation_id", UUID.randomUUID().toString());
        body.put("capability", capability);
        body.put("payload", payload == null ? new JSONObject() : payload);
        body.put("constraints", constraints == null ? new JSONObject() : constraints);
        if (targetNode != null && !targetNode.trim().isEmpty()) body.put("target_node", targetNode.trim());
        body.put("requested_by", "atlas-android-assistant");
        body.put("source_system", "ARK-OS/Atlas-Android");
        body.put("proof_required", true);
        body.put("memory_return_required", true);
        body.put("timeout_ms", 240_000);
        return request("POST", "/v1/assistant/command-to-proof", body, 260_000);
    }

    public static String renderConsoleUrl() {
        return BuildConfig.RUNTIME_BASE_URL + "/assistant";
    }

    private static JSONObject request(String method, String path, JSONObject body, int readTimeoutMs) throws Exception {
        URL url = new URL(BuildConfig.RUNTIME_BASE_URL + path);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod(method);
        connection.setConnectTimeout(8_000);
        connection.setReadTimeout(readTimeoutMs);
        connection.setRequestProperty("Accept", "application/json");
        connection.setRequestProperty("User-Agent", "ghost-atlas-ark-android/0.3");

        if (body != null) {
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            byte[] bytes = body.toString().getBytes(StandardCharsets.UTF_8);
            try (OutputStream output = connection.getOutputStream()) {
                output.write(bytes);
            }
        }

        int status = connection.getResponseCode();
        BufferedReader reader = new BufferedReader(new InputStreamReader(
                status >= 200 && status < 300 ? connection.getInputStream() : connection.getErrorStream(),
                StandardCharsets.UTF_8));
        try (reader) {
            String responseBody = reader.lines().collect(Collectors.joining("\n"));
            if (status < 200 || status >= 300) {
                throw new IOException("Atlas runtime HTTP " + status + ": " + responseBody);
            }
            return new JSONObject(responseBody);
        } finally {
            connection.disconnect();
        }
    }
}
