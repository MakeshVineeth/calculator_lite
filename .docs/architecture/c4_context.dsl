workspace "Calculator Lite System Context" "High-level system context diagram for Calculator Lite" {

    model {
        user = person "Mobile App User" "Calculates arithmetic, performs currency conversions, and analyzes calculation history."
        
        calcApp = softwareSystem "Calculator Lite" "Fast, secure mobile calculator with real-time currency conversions, history tracking, and spreadsheet export."
        
        currencyApi = softwareSystem "Exchange Rate API" "Provides real-time and historical foreign exchange rates for 150+ currencies." "External System"
        
        playBilling = softwareSystem "Google Play In-App Billing" "Handles premium purchases, product verification, and licensing." "External System"

        user -> calcApp "Inputs calculations, converts currencies, and views history"
        calcApp -> currencyApi "Fetches foreign exchange rates over HTTPS (TLS 1.3)"
        calcApp -> playBilling "Queries product SKU details and processes one-time purchases"
    }

    views {
        systemContext calcApp "SystemContext" {
            include *
            autoLayout lr
        }

        styles {
            element "Software System" {
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
