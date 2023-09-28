#include "AudioDevice.h"
#include <iostream>
#include <Windows.h>
#include <Mmdeviceapi.h>

std::vector<std::string> AudioDevice::listAudioDevices() {
    std::vector<std::string> devices;

    IMMDeviceEnumerator* pEnumerator = NULL;
    IMMDeviceCollection* pCollection = NULL;

    CoInitialize(NULL);

    HRESULT hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), (void**)&pEnumerator);
    if (FAILED(hr)) {
        std::cerr << "Failed to create multimedia device enumerator." << std::endl;
        return devices;
    }

    hr = pEnumerator->EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE, &pCollection);
    if (FAILED(hr)) {
        pEnumerator->Release();
        return devices;
    }

    UINT deviceCount = 0;
    hr = pCollection->GetCount(&deviceCount);
    if (FAILED(hr)) {
        pCollection->Release();
        pEnumerator->Release();
        return devices;
    }

    for (UINT i = 0; i < deviceCount; ++i) {
        IMMDevice* pDevice = NULL;
        hr = pCollection->Item(i, &pDevice);
        if (SUCCEEDED(hr)) {
            LPWSTR pwszID = NULL;
            hr = pDevice->GetId(&pwszID);
            if (SUCCEEDED(hr)) {
                char deviceName[MAX_PATH];
                WideCharToMultiByte(CP_UTF8, 0, pwszID, -1, deviceName, MAX_PATH, NULL, NULL);
                devices.push_back(deviceName);
                CoTaskMemFree(pwszID);
            }
            pDevice->Release();
        }
    }

    pCollection->Release();
    pEnumerator->Release();
    CoUninitialize();

    return devices;
}

void AudioDevice::initializeAudioDeviceMonitoring(void (*callback)()) {
    // Implement code to monitor audio device changes using OpenAL
    // Call the callback function when a device change is detected
}
