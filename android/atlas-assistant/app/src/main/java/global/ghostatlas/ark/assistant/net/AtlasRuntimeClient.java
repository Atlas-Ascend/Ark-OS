package global.ghostatlas.ark.assistant.net;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

import global.ghostatlas.ark.assistant.BuildConfig;

public final class AtlasRuntimeClient {
    private AtlasRuntimeClient() {}

    public static JSONObject getResidentBrief() throws Exception {
        return request("GET", "/v1/sami/brief", null);
    }

    public static JSONObject submitCommand(String command) throws Exception {
        JSONObject body = new JSONObject();
        body.put("command", command);
        body.put("requested_by", "atlas-android-assistant");
        return request("POST", "/v1/commands", body);
    }

    private static JSONObject request(String method, String path, JSONObject body) throws Exception {
        URL url = new URL(BuildConfig.RUNTIME_BASE_URL + path);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod(method);
        connection.setConnectTimeout(8_000);
        connection.setReadTimeout(20_000);
        connection.setRequestProperty("Accept", "application/json");
        connection.setRequestProperty("User-Agent", "ghost-atlas-ark-android/0.1");

        if (body != null) {
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            byte[] bytes = body.toString().getBytes(StandardCharsets.UTF_8);
            try (OutputStream output = connection.getOutputStream()) {
                output.write(bytes);
            }
        }

        int status = connection.getResponseCode();
        if (status < 200 || status >= 300) {
            throw new IOException("Atlas runtime HTTP " + status);
        }
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            String payload = reader.lines().collect(Collectors.joining("\n"));
            return new JSONObject(payload);
        } finally {
            connection.disconnect();
        }
    }
}
