# Themes

@Metadata {

    @PageImage(
        purpose: card,
        source: "Page",
        alt: "Page icon"
    )

    @PageColor(blue)
}

This article describes the KeyboardKit Pro theme engine, which can be used to style the entire keyboard with a single theme.

👑 [KeyboardKit Pro][Pro] unlocks a theme engine that makes it easier to style your keyboard, as well as many predefined themes and theme-based views. You can easily create your own themes as well.

[Pro]: https://github.com/KeyboardKit/KeyboardKitPro



## Namespace

KeyboardKit has a ``KeyboardTheme`` type that is also a namespace for theme-related types and views, like ``KeyboardTheme/Shelf`` and ``KeyboardTheme/ShelfItem``.



## Context

KeyboardKit has an observable ``KeyboardThemeContext`` class that can be used to handle themes and auto-persisted ``FeedbackContext/settings-swift.property``. It also has auto-persisted ``KeyboardThemeContext/settings-swift.property`` that can be used to persist themes.

KeyboardKit automatically creates an instance of this class, injects it into ``KeyboardInputViewController/state`` and updates it whenever the theme changes.



## Themes

A ``KeyboardTheme`` can provide keyboard-related styles in a way that can be easily used and modified. A theme can also define style variations that can be used to customize a constrained set of theme properties.

KeyboardKit Pro unlocks a bunch of themes and style variations, as well as a ``KeyboardStyle/ThemeBasedService`` ``KeyboardStyleService`` that lets you apply themes with the style service concept that is used by some views, like the ``KeyboardView``.

KeyboardKit Pro unlocks many standard themes, like ``KeyboardTheme/standard``, ``KeyboardTheme/swifty`` and ``KeyboardTheme/minimal``. These themes also have style variations, that lets you vary their appearance, like the standard theme's ``KeyboardTheme/StandardStyle/blue`` and ``KeyboardTheme/StandardStyle/green`` variations:

@TabNavigator {
    @Tab(".standard") {
        @Row {
            @Column { 
                ![standard](standard) 
            }
            @Column { 
                ![blue](standard-blue) 
            }
            @Column { 
                ![green](standard-green) 
            }   
        }
    }
    @Tab(".swifty") {
        @Row {
            @Column { 
                ![standard](swifty) 
            }
            @Column { 
                ![blue](swifty-blue) 
            }
            @Column { 
                ![green](swifty-green) 
            }   
        }
    }
    @Tab(".minimal") {
        @Row {
            @Column { 
                ![standard](minimal) 
            }
            @Column { 
                ![blue](minimal-blue) 
            }
            @Column { 
                ![subset](minimal-sunset) 
            }   
        }
    }
}

KeyboardKit Pro also unlocks other more expressive themes, which provide their own unique visual baseline:

@TabNavigator {
    @Tab(".aesthetic") {
        @Row {
            @Column { 
                ![boho](aesthetic-boho) 
            }
            @Column {}
            @Column {}
        }
    }
    @Tab(".candyShop") {
        @Row {
            @Column { 
                ![standard](candyshop) 
            }
            @Column { 
                ![cuppycake](candyshop-cuppycake) 
            }
            @Column {}
        }
    }
    @Tab(".colorful") {
        @Row {
            @Column { 
                ![blue](colorful-blue) 
            }
            @Column { 
                ![green](colorful-green) 
            }   
            @Column { 
                ![standard](colorful-orange) 
            }
        }
    }
    @Tab(".neon") {
        @Row {
            @Column { 
                ![standard](neon) 
            }
            @Column {}
            @Column {}
        }
    }
    @Tab(".tron") {
        @Row {
            @Column { 
                ![blue](tron) 
            }
            @Column { 
                ![fcon](tron-fcon) 
            }   
            @Column { 
                ![virus](tron-virus) 
            }   
        }
    }
}

You can get a list of all predefined themes, as well as all pre-defined style variations, using the static ``KeyboardTheme/allPredefined`` properties. You can create your own themes, as well as custom style variations for all predefined themes.



## Views

KeyboardKit Pro unlocks views in the ``KeyboardTheme`` namespace, that make it easy to preview and present keyboard themes:

@TabNavigator {
    @Tab("Shelf"){
        @Row {
            @Column { ![ThemeShelf](themeshelf) }
            @Column {
                A keyboard theme ``KeyboardTheme/Shelf`` can be used to list themes in a vertical list of horizontally scrolling shelves.
                
                You can use the standard ``KeyboardTheme/ShelfItem`` to show how a ``Keyboard/Button`` will look, or use completely custom views for the titles and items.
            }
        }
    }
}




---


## How to...


### Apply a theme

You can apply theme with the ``KeyboardStyle/ThemeBasedService`` service, or the ``KeyboardStyleService/themeBased(theme:keyboardContext:)`` shorthand:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setupPro(for: .myApp) { license in
        self.services.styleService = .themeBased(
            theme: .standard,
            keyboardContext: state.keyboardContext
        )
    } 
}
```

You can inherit ``KeyboardStyle/ThemeBasedService`` to customize the theme even further, which lets you mix the benefits of themes and styles.



### Create a custom theme

Since a ``KeyboardTheme`` is just a struct, you can easily create your own custom themes by just defining new static theme value types. 

For instance, this theme only changes the color of the primary button:

```swift
extension KeyboardTheme {

    static var greenPrimary: Self {
        get throws {
            try? Self(primaryBackgroundColor: .green)
        }
    }
}
```

You can also use other themes as a base when creating your own custom themes, if you only want to change a small part of a theme. 

For instance, this theme starts with the minimal theme and changes the color of the primary button to pink:

```swift
extension KeyboardTheme {

    static var pinkPrimary: Self {
        get throws {
            var theme = try? KeyboardTheme.minimal
            theme.buttonStyles[.primary]?.backgroundColor = .green
            return theme
        }
    }
}
```

You can also create custom themes that just tweak a style variation of another theme. 

For instance, this custom theme is a standard theme that applies a black tint color style variation:

```swift
extension KeyboardTheme {

    static var standardBlack: Self {
        .standard(.init(tint: .black))
    }
}
```

All these combinations make the theme engine very flexible and powerful.
