#pragma once

#include <vector>
#include <string>

class AudioDeviceManager {
public:
    static std::vector<std::string> listAudioDevices();
    static void initializeAudioDeviceMonitoring(void (*callback)());
};