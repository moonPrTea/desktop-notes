import AppKit

extension AppDelegate {
    func installMenus() {
        let main = NSMenu()
        let appItem = main.addItem(withTitle: "Desktop Notes", action: nil, keyEquivalent: "")
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Завершить Desktop Notes", action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")
        appItem.submenu = appMenu
        let fileItem = main.addItem(withTitle: "Листик", action: nil, keyEquivalent: "")
        let fileMenu = NSMenu(title: "Листик")
        add("Новый листик", #selector(createNote), to: fileMenu, key: "n")
        add("Смахнуть листик", #selector(hideCurrent), to: fileMenu, key: "w")
        fileItem.submenu = fileMenu
        let editItem = main.addItem(withTitle: "Правка", action: nil, keyEquivalent: "")
        let editMenu = NSMenu(title: "Правка")
        let edits: [(String, String, String)] = [
            ("Отменить", "undo:", "z"), ("Повторить", "redo:", "Z"),
            ("Вырезать", "cut:", "x"), ("Копировать", "copy:", "c"),
            ("Вставить", "paste:", "v"), ("Выделить всё", "selectAll:", "a")
        ]
        for (title, action, key) in edits {
            editMenu.addItem(withTitle: title, action: Selector(action), keyEquivalent: key)
        }
        editItem.submenu = editMenu
        NSApp.mainMenu = main
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "note.text",
                                           accessibilityDescription: "Desktop Notes")
        statusItem.button?.toolTip = "Desktop Notes — твои листики"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let heading = menu.addItem(withTitle: "desktop notes", action: nil, keyEquivalent: "")
        heading.isEnabled = false
        add("Новый листик", #selector(createNote), to: menu, key: "n")
        add("Показать все листики", #selector(showAll), to: menu)
        add("Смахнуть все", #selector(hideAll), to: menu)
        menu.addItem(.separator())
        for note in store.notes where !note.isDeleted {
            let item = add(note.title, #selector(restoreNote), to: menu)
            item.representedObject = note.id
            item.state = note.isHidden ? .off : .on
        }
        let deleted = store.notes.filter(\.isDeleted)
        let trash = NSMenu(title: "Корзина")
        if deleted.isEmpty {
            trash.addItem(withTitle: "Здесь пусто", action: nil, keyEquivalent: "")
        } else {
            for note in deleted {
                let item = add("Вернуть: " + note.title, #selector(restoreNote), to: trash)
                item.representedObject = note.id
            }
        }
        menu.addItem(.separator())
        let trashItem = menu.addItem(withTitle: "Корзина (\(deleted.count))", action: nil, keyEquivalent: "")
        trashItem.submenu = trash
        add("Как пользоваться", #selector(showHelp), to: menu)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Завершить", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @discardableResult
    private func add(_ title: String, _ action: Selector, to menu: NSMenu, key: String = "") -> NSMenuItem {
        let item = menu.addItem(withTitle: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Маленькие листики. Большие идеи."
        alert.informativeText = "Пиши прямо на листике. Перетаскивай за белое поле, меняй размер за край.\n\nПалитра меняет цвет, булавка держит листик поверх окон. Без булавки он остаётся на рабочем столе.\n\nСмахни двумя пальцами по белому полю или нажми минус, чтобы спрятать. Верни через меню в строке macOS.\n\nУдалённые листики можно вернуть из корзины. Всё сохраняется на этом Mac автоматически.\n\n⌘N — новый листик · ⌘W — спрятать · ⌘Z — отменить правку."
        alert.runModal()
    }
}
