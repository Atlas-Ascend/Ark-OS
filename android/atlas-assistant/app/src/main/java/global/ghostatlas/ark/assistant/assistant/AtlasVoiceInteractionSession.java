package global.ghostatlas.ark.assistant.assistant;

import android.app.assist.AssistContent;
import android.app.assist.AssistStructure;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.service.voice.VoiceInteractionSession;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.JSONObject;

import global.ghostatlas.ark.assistant.net.AtlasRuntimeClient;

public final class AtlasVoiceInteractionSession extends VoiceInteractionSession {
    private TextView status;
    private volatile String foregroundPackage;

    public AtlasVoiceInteractionSession(Context context) {
        super(context);
    }

    @Override
    public View onCreateContentView() {
        LinearLayout root = new LinearLayout(getContext());
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        root.setPadding(48, 48, 48, 48);

        TextView title = new TextView(getContext());
        title.setText("ATLAS / Resident GARI");
        title.setTextSize(22f);
        root.addView(title);

        status = new TextView(getContext());
        status.setText("Connecting to Ghost Atlas…");
        status.setTextSize(16f);
        status.setPadding(0, 24, 0, 0);
        root.addView(status);
        return root;
    }

    @Override
    public void onShow(Bundle args, int showFlags) {
        super.onShow(args, showFlags);
        refreshBrief();
    }

    @Override
    public void onHandleAssist(AssistState state) {
        super.onHandleAssist(state);
        if (state.getActivityId() != null) {
            foregroundPackage = state.getActivityId().getComponentName().getPackageName();
        }
    }

    @Override
    public void onHandleAssist(Bundle data, AssistStructure structure, AssistContent content) {
        super.onHandleAssist(data, structure, content);
    }

    @Override
    public void onHandleScreenshot(Bitmap screenshot) {
        super.onHandleScreenshot(screenshot);
        // V0 deliberately does not upload screenshots. ARGUS handoff is a later, explicit capability.
    }

    private void refreshBrief() {
        new Thread(() -> {
            try {
                JSONObject brief = AtlasRuntimeClient.getResidentBrief();
                JSONObject counts = brief.optJSONObject("counts");
                String text = "Atlas online";
                if (counts != null) {
                    text += "\nResident state: " + counts.toString();
                }
                if (foregroundPackage != null) {
                    text += "\nForeground: " + foregroundPackage;
                }
                final String rendered = text;
                if (status != null) {
                    status.post(() -> status.setText(rendered));
                }
            } catch (Exception error) {
                if (status != null) {
                    status.post(() -> status.setText("Atlas runtime degraded: " + error.getMessage()));
                }
            }
        }, "atlas-resident-brief").start();
    }
}
