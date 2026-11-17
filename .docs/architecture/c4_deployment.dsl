workspace "Calculator Lite Deployment" "Deployment diagram representing client runtime environment" {

    model {
        mobileDevice = deploymentNode "User Mobile Device" "Android or iOS Smartphone/Tablet" "Hardware / OS" {
            appSandbox = deploymentNode "App Sandbox" "OS Application Isolation Boundary" "Security Sandbox" {
                flutterApp = containerInstance "Calculator Lite Application" "Compiled Flutter Engine + Dart AOT Binary"
                hiveStorage = containerInstance "Hive CE NoSQL Storage" "Local Encrypted/Sandboxed Documents Directory"
                sharedPrefs = containerInstance "Platform SharedPreferences" "Key-Value Configuration Cache"
            }
            osServices = deploymentNode "OS Platform Layer" "Android Runtime / iOS Darwin" {
                windowManager = containerInstance "Window Manager" "Controls FLAG_SECURE screen privacy"
                connectivity = containerInstance "Network Stack" "Enforces TLS 1.3 / Cleartext disabled"
            }
        }
        
        cloudServices = deploymentNode "External Cloud Infrastructure" "High-availability internet services" {
            exchangeApiServer = containerInstance "Exchange Rate API Server" "HTTPS JSON Endpoint"
            googlePlayStore = containerInstance "Google Play Services" "In-App Billing & Licensing Gateway"
        }

        flutterApp -> hiveStorage "Reads & writes history and offline currency cache"
        flutterApp -> sharedPrefs "Reads & writes app settings and theme"
        flutterApp -> windowManager "Toggles screen protection"
        flutterApp -> connectivity "Dispatches outbound requests"
        connectivity -> exchangeApiServer "Fetches rates over HTTPS"
        flutterApp -> googlePlayStore "Verifies purchases via Play Billing API"
    }

    views {
        deployment * "Deployment" {
            include *
            autoLayout tb
        }

        styles {
            element "Container Instance" {
                background #00796B
                color #ffffff
            }
        }
    }
}
