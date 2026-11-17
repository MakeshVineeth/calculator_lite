workspace "Calculator Lite Containers" "Container diagram showing high-level architectural building blocks" {

    model {
        user = person "Mobile App User" "Calculates arithmetic, performs currency conversions, and analyzes calculation history."
        
        calcApp = softwareSystem "Calculator Lite" {
            uiContainer = container "Presentation Container (Flutter UI)" "Renders responsive Material 3 UI, keypad, displays, and charts." "Flutter / Dart"
            stateContainer = container "State Management Container" "Manages reactive state via ChangeNotifier/Provider pattern." "Flutter Provider / Dart"
            domainContainer = container "Domain & Engine Container" "Parses expressions, tokenizes formulas, and computes numerical evaluations." "Pure Dart"
            dataContainer = container "Data & Persistence Container" "Manages local Hive NoSQL database, SharedPreferences, and file exports." "Hive CE / PathProvider"
            networkContainer = container "Network Client Container" "Handles secure REST API requests with timeouts and retry mechanisms." "Dio Client / HTTPS"
        }
        
        currencyApi = softwareSystem "Exchange Rate API" "Provides real-time foreign exchange rates." "External System"
        playBilling = softwareSystem "Google Play In-App Billing" "Processes in-app purchases." "External System"

        user -> uiContainer "Interacts with screens, keypads, and tabs"
        uiContainer -> stateContainer "Dispatches user intents and events"
        stateContainer -> domainContainer "Executes mathematical logic and validation"
        stateContainer -> dataContainer "Persists calculation history and user settings"
        stateContainer -> networkContainer "Requests fresh currency rates"
        networkContainer -> currencyApi "Fetches rates via HTTPS / TLS"
        uiContainer -> playBilling "Initiates purchase flows"
    }

    views {
        container calcApp "Containers" {
            include *
            autoLayout tb
        }

        styles {
            element "Container" {
                background #00796B
                color #ffffff
            }
            element "External System" {
                background #546E7A
                color #ffffff
            }
            element "Person" {
                background #004D40
                color #ffffff
                shape Person
            }
        }
    }
}
