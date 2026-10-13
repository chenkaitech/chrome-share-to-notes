// ShareToNotes: Chrome native-messaging host + share-sheet helper.
//
// Launched by Chrome (first arg is "chrome-extension://..."): reads one native
// message {url, title}, relaunches this app bundle in share mode, replies, exits.
// Launched with "--share <url>": presents the system Notes share extension
// (the same one Safari uses), so Notes builds the rich link preview itself.
import AppKit

let args = CommandLine.arguments

func readNativeMessage() -> [String: Any]? {
    let stdin = FileHandle.standardInput
    let header = stdin.readData(ofLength: 4)
    guard header.count == 4 else { return nil }
    let length = header.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
    let body = stdin.readData(ofLength: Int(length))
    return (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
}

func writeNativeMessage(_ object: [String: Any]) {
    guard let body = try? JSONSerialization.data(withJSONObject: object) else { return }
    var length = UInt32(body.count)
    FileHandle.standardOutput.write(Data(bytes: &length, count: 4))
    FileHandle.standardOutput.write(body)
}

func runNativeHost() -> Never {
    guard let message = readNativeMessage(),
          let urlString = message["url"] as? String,
          let url = URL(string: urlString),
          ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
        writeNativeMessage(["ok": false, "error": "invalid url"])
        exit(1)
    }
    // A separate, detached instance shows the share UI so Chrome can close this host.
    let open = Process()
    open.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    open.arguments = ["-n", "-a", Bundle.main.bundlePath, "--args", "--share", url.absoluteString]
    do {
        try open.run()
        open.waitUntilExit()
        if open.terminationStatus != 0 { throw NSError(domain: "open", code: Int(open.terminationStatus)) }
        writeNativeMessage(["ok": true])
        exit(0)
    } catch {
        writeNativeMessage(["ok": false, "error": "launch failed: \(error.localizedDescription)"])
        exit(1)
    }
}

final class ShareController: NSObject, NSApplicationDelegate, NSSharingServiceDelegate {
    let url: URL
    init(url: URL) { self.url = url }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let service = NSSharingService(named: NSSharingService.Name("com.apple.Notes.SharingExtension")) else {
            NSLog("ShareToNotes: Notes sharing extension not available")
            NSApp.terminate(nil)
            return
        }
        service.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        service.perform(withItems: [url as NSURL])
        // Safety net in case the share UI never reports back.
        DispatchQueue.main.asyncAfter(deadline: .now() + 600) { NSApp.terminate(nil) }
    }

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        NSApp.terminate(nil)
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        NSApp.terminate(nil)
    }
}

if args.count > 1, args[1].hasPrefix("chrome-extension://") {
    runNativeHost()
} else if args.count > 2, args[1] == "--share", let url = URL(string: args[2]) {
    let app = NSApplication.shared
    let controller = ShareController(url: url)
    app.delegate = controller
    app.setActivationPolicy(.accessory)
    app.run()
} else {
    FileHandle.standardError.write("usage: ShareToNotes --share <url>\n".data(using: .utf8)!)
    exit(2)
}
