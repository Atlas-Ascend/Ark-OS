package global.ghostatlas.ark.assistant.assistant;

import android.service.voice.VoiceInteractionSession;
import android.service.voice.VoiceInteractionSessionService;

public final class AtlasVoiceInteractionSessionService extends VoiceInteractionSessionService {
    @Override
    public VoiceInteractionSession onNewSession(android.os.Bundle args) {
        return new AtlasVoiceInteractionSession(this);
    }
}
