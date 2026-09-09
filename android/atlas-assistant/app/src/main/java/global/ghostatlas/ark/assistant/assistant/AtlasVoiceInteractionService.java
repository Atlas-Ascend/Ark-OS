package global.ghostatlas.ark.assistant.assistant;

import android.os.Bundle;
import android.service.voice.VoiceInteractionService;
import android.service.voice.VoiceInteractionSession;

public final class AtlasVoiceInteractionService extends VoiceInteractionService {
    @Override
    public void onLaunchVoiceAssistFromKeyguard() {
        showSession(new Bundle(),
                VoiceInteractionSession.SHOW_WITH_ASSIST
                        | VoiceInteractionSession.SHOW_WITH_SCREENSHOT);
    }
}
