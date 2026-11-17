workspace "Calculator Lite Components" "Component diagram for features and core modules" {

    model {
        calcApp = softwareSystem "Calculator Lite" {
            container "Application Runtime" {
                calcFeature = component "Calculator Feature" "Handles expression input, tokenizer, and scientific calculations" "Feature Module"
                currencyFeature = component "Currency Feature" "Handles exchange rate synchronization and currency conversion" "Feature Module"
                historyFeature = component "History Feature" "Stores, indexes, filters, and manages historical calculations" "Feature Module"
                exportFeature = component "Export Feature" "Generates formatted Excel (.xlsx) and CSV reports" "Feature Module"
                proFeature = component "Pro Upgrade Feature" "Handles billing status, feature unlocking, and paywall" "Feature Module"
                securityCore = component "Security & System Core" "Enforces OWASP sanitization, secure window flags, and theming" "Core Module"
            }
        }

        calcFeature -> historyFeature "Saves completed calculation"
        calcFeature -> securityCore "Validates expression syntax and input boundaries"
        historyFeature -> exportFeature "Supplies historical items for export"
        proFeature -> exportFeature "Unlocks advanced export capabilities"
        currencyFeature -> securityCore "Uses secure HTTPS and network configuration"
    }

    views {
        component "Application Runtime" "Components" {
            include *
            autoLayout tb
        }

        styles {
            element "Component" {
                background #00796B
                color #ffffff
            }
        }
    }
}
