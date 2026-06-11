const injectionPatterns = [
    /ignore\s+all\s+(previous\s+)?instructions/i,
    /disregard\s+all\s+prior\s+instructions/i,
    /forget\s+everything\s+I\s+told\s+you/i,
    /ігноруй\s+(всі\s+)?(попередні\s+)?інструкції/i,
    /забудь\s+(все,\s+що\s+я\s+тобі\s+казав|попередні\s+вказівки)/i,
    /не\s+звертай\s+уваги\s+на\s+попередні\s+правила/i,

    /you\s+are\s+now/i,
    /act\s+as/i,
    /please\s+pretend\s+to\s+be/i,
    /тепер\s+ти/i,
    /дій(с|сн|суй)?\s+як/i,
    /уяви,\s+що\s+ти/i,
    /стань\s+на\s+момент/i,

    /system\s+prompt/i,
    /show\s+me\s+your\s+code/i,
    /return\s+password/i,
    /confidential\s+information/i,
    /покажи\s+(свій\s+)?(системний\s+)?промпт/i,
    /твій\s+код/i,
    /конфіденційна\s+інформація/i,
    /службові\s+інструкції/i,

    /developer\s+mode/i,
    /unfiltered/i,
    /disable\s+safety/i,
    /execute\s+command/i,
    /hacked/i,
    /admin/i,
    /bypass/i,
    /режим\s+розробника/i,
    /вимкни\s+захист/i,
    /адмін(істратор)?/i,
    /виконай\s+команду/i,

    /as\s+an\s+ai\s+language\s+model/i,
    /як\s+штучний\s+інтелект/i,
    /я\s+мовна\s+модель/i
];

export function isPromptInjection(userMessage) {
    return injectionPatterns.some(pattern => pattern.test(userMessage));
}
