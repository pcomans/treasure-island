class_name SentryBackend
extends RefCounted
## The one script that calls Sentry's Godot add-on (addons/sentry, release 2.5.1, owner
## 2026-11-17): DesktopReports goes through these methods only, so a test hands it a
## stand-in with the same methods (game/tests/headless_desktop_reports_contract.gd). The
## add-on is reached by name (its engine singleton and ClassDB), never by class name, so
## the game parses and runs where the add-on did not load: the web build, which leaves it
## out, a Linux machine without the libcurl or glibc 2.34 its library needs, and a
## checkout run from source before the editor has registered it.

const SDK_SINGLETON := "SentrySDK"

var _sdk: Object


func _init() -> void:
	if Engine.has_singleton(SDK_SINGLETON):
		_sdk = Engine.get_singleton(SDK_SINGLETON)


## Whether the add-on loaded.
func available() -> bool:
	return _sdk != null


## Whether the SDK is started (init) and not closed.
func is_enabled() -> bool:
	return _sdk != null and bool(_sdk.is_enabled())


## Starts the SDK, configure(options) setting its options (SentryOptions) first.
## Returns whether it started.
func init(configure: Callable) -> bool:
	if _sdk == null or is_enabled():
		return false
	_sdk.init(configure)
	return is_enabled()


## Closes the SDK at once: nothing more is captured or sent.
func close() -> void:
	if is_enabled():
		_sdk.close()


## The reports' user id from now on ("" for none).
func set_user_id(id: String) -> void:
	if _sdk == null:
		return
	if id.is_empty():
		_sdk.remove_user()
	else:
		_sdk.set_user(new_user(id))


## A user (SentryUser) with this id and nothing else, for set_user or an event's.
func new_user(id: String) -> Object:
	var user: Object = ClassDB.instantiate("SentryUser")
	user.set("id", id)
	return user


## Replaces a context on the scope every later report carries.
func set_context(key: String, value: Dictionary) -> void:
	if _sdk != null:
		_sdk.set_context(key, value)


## Sets these tags on the scope, keeping the others.
func set_tags(tags: Dictionary) -> void:
	if _sdk != null:
		_sdk.set_tags(tags)


## A new trace for what follows (a new day's id, say).
func start_new_trace() -> void:
	if _sdk != null:
		_sdk.start_new_trace()


## A transaction: a new root span named name, with these attributes (its "sentry.op"
## among them), not made the scope's active span. End it with end_span.
func start_transaction(name: String, attributes: Dictionary) -> Object:
	if _sdk == null:
		return null
	return _sdk.start_span(name, attributes, null, false)


## A child span of parent, inactive too.
func start_child(parent: Object, name: String, attributes: Dictionary) -> Object:
	if _sdk == null or parent == null:
		return null
	return _sdk.start_span(name, attributes, parent, false)


func end_span(span: Object) -> void:
	if span != null:
		span.end()
