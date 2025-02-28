const std = @import("std");
const JSC = @import("javascript_core");
const strings = @import("strings");
const bun = @import("../global.zig");
const Lock = @import("../lock.zig").Lock;
const JSValue = JSC.JSValue;
const ZigString = JSC.ZigString;
const TODO_EXCEPTION: JSC.C.ExceptionRef = null;

const Channel = @import("../sync.zig").Channel;

pub const napi_env = *JSC.JSGlobalObject;
pub const napi_ref = struct_napi_ref__;
pub const napi_handle_scope = napi_env;
pub const napi_escapable_handle_scope = struct_napi_escapable_handle_scope__;
pub const napi_callback_info = *JSC.CallFrame;
pub const napi_deferred = *JSC.JSPromise;

pub const napi_value = JSC.JSValue;
pub const struct_napi_ref__ = opaque {};
pub const struct_napi_escapable_handle_scope__ = opaque {};
pub const struct_napi_deferred__ = opaque {};

const char16_t = u16;
pub const napi_default: c_int = 0;
pub const napi_writable: c_int = 1;
pub const napi_enumerable: c_int = 2;
pub const napi_configurable: c_int = 4;
pub const napi_static: c_int = 1024;
pub const napi_default_method: c_int = 5;
pub const napi_default_jsproperty: c_int = 7;
pub const napi_property_attributes = c_uint;
pub const napi_valuetype = enum(c_uint) {
    @"undefined" = 0,
    @"null" = 1,
    @"boolean" = 2,
    @"number" = 3,
    @"string" = 4,
    @"symbol" = 5,
    @"object" = 6,
    @"function" = 7,
    @"external" = 8,
    @"bigint" = 9,
};
pub const napi_typedarray_type = enum(c_uint) {
    int8_array = 0,
    uint8_array = 1,
    uint8_clamped_array = 2,
    int16_array = 3,
    uint16_array = 4,
    int32_array = 5,
    uint32_array = 6,
    float32_array = 7,
    float64_array = 8,
    bigint64_array = 9,
    biguint64_array = 10,

    pub fn fromJSType(this: JSC.JSValue.JSType) ?napi_typedarray_type {
        return switch (this) {
            .Int8Array => napi_typedarray_type.int8_array,
            .Uint8Array => napi_typedarray_type.uint8_array,
            .Uint8ClampedArray => napi_typedarray_type.uint8_clamped_array,
            .Int16Array => napi_typedarray_type.int16_array,
            .Uint16Array => napi_typedarray_type.uint16_array,
            .Int32Array => napi_typedarray_type.int32_array,
            .Uint32Array => napi_typedarray_type.uint32_array,
            .Float32Array => napi_typedarray_type.float32_array,
            .Float64Array => napi_typedarray_type.float64_array,
            .BigInt64Array => napi_typedarray_type.bigint64_array,
            .BigUint64Array => napi_typedarray_type.biguint64_array,
            else => null,
        };
    }

    pub fn toJSType(this: napi_typedarray_type) JSC.JSValue.JSType {
        return switch (this) {
            .int8_array => .Int8Array,
            .uint8_array => .Uint8Array,
            .uint8_clamped_array => .Uint8ClampedArray,
            .int16_array => .Int16Array,
            .uint16_array => .Uint16Array,
            .int32_array => .Int32Array,
            .uint32_array => .Uint32Array,
            .float32_array => .Float32Array,
            .float64_array => .Float64Array,
            .bigint64_array => .BigInt64Array,
            .biguint64_array => .BigUint64Array,
        };
    }

    pub fn toC(this: napi_typedarray_type) JSC.C.JSTypedArrayType {
        return this.toJSType().toC();
    }
};
pub const napi_status = enum(c_uint) {
    ok = 0,
    invalid_arg = 1,
    object_expected = 2,
    string_expected = 3,
    name_expected = 4,
    function_expected = 5,
    number_expected = 6,
    boolean_expected = 7,
    array_expected = 8,
    generic_failure = 9,
    pending_exception = 10,
    cancelled = 11,
    escape_called_twice = 12,
    handle_scope_mismatch = 13,
    callback_scope_mismatch = 14,
    queue_full = 15,
    closing = 16,
    bigint_expected = 17,
    date_expected = 18,
    arraybuffer_expected = 19,
    detachable_arraybuffer_expected = 20,
    would_deadlock = 21,
};
pub const napi_callback = ?fn (napi_env, napi_callback_info) callconv(.C) napi_value;
pub const napi_finalize = ?fn (napi_env, ?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const napi_property_descriptor = extern struct {
    utf8name: [*c]const u8,
    name: napi_value,
    method: napi_callback,
    getter: napi_callback,
    setter: napi_callback,
    value: napi_value,
    attributes: napi_property_attributes,
    data: ?*anyopaque,
};
pub const napi_extended_error_info = extern struct {
    error_message: [*c]const u8,
    engine_reserved: ?*anyopaque,
    engine_error_code: u32,
    error_code: napi_status,
};
pub const napi_key_include_prototypes: c_int = 0;
pub const napi_key_own_only: c_int = 1;
pub const napi_key_collection_mode = c_uint;
pub const napi_key_all_properties: c_int = 0;
pub const napi_key_writable: c_int = 1;
pub const napi_key_enumerable: c_int = 2;
pub const napi_key_configurable: c_int = 4;
pub const napi_key_skip_strings: c_int = 8;
pub const napi_key_skip_symbols: c_int = 16;
pub const napi_key_filter = c_uint;
pub const napi_key_keep_numbers: c_int = 0;
pub const napi_key_numbers_to_strings: c_int = 1;
pub const napi_key_conversion = c_uint;
pub const napi_type_tag = extern struct {
    lower: u64,
    upper: u64,
};
pub extern fn napi_get_last_error_info(env: napi_env, result: [*c][*c]const napi_extended_error_info) napi_status;
pub export fn napi_get_undefined(_: napi_env, result: *napi_value) napi_status {
    result.* = JSValue.jsUndefined();
    return .ok;
}
pub export fn napi_get_null(_: napi_env, result: *napi_value) napi_status {
    result.* = JSValue.jsNull();
    return .ok;
}
pub extern fn napi_get_global(env: napi_env, result: *napi_value) napi_status;
pub export fn napi_get_boolean(_: napi_env, value: bool, result: *napi_value) napi_status {
    result.* = JSValue.jsBoolean(value);
    return .ok;
}
pub export fn napi_create_object(env: napi_env, result: *napi_value) napi_status {
    result.* = JSValue.createEmptyObject(env, 0);
    return .ok;
}
pub export fn napi_create_array(env: napi_env, result: *napi_value) napi_status {
    result.* = JSValue.c(JSC.C.JSObjectMakeArray(env.ref(), 0, null, null));
    return .ok;
}
const prefilled_undefined_args_array: [128]JSC.JSValue = brk: {
    var args: [128]JSC.JSValue = undefined;
    for (args) |_, i| {
        args[i] = JSValue.jsUndefined();
    }
    break :brk args;
};
pub export fn napi_create_array_with_length(env: napi_env, length: usize, result: *napi_value) napi_status {
    if (length < prefilled_undefined_args_array.len) {
        result.* = JSValue.c(JSC.C.JSObjectMakeArray(env.ref(), length, @ptrCast([*]const JSC.C.JSValueRef, &prefilled_undefined_args_array[0..length]), null));
        return .ok;
    }

    const allocator = env.bunVM().allocator;
    var undefined_args = allocator.alloc(JSC.C.JSValueRef, length) catch return .generic_failure;
    defer allocator.free(undefined_args);
    for (undefined_args) |_, i| {
        undefined_args[i] = JSValue.jsUndefined().asObjectRef();
    }
    result.* = JSValue.c(JSC.C.JSObjectMakeArray(env.ref(), length, undefined_args.ptr, null));

    return .ok;
}
pub export fn napi_create_double(_: napi_env, value: f64, result: *napi_value) napi_status {
    result.* = JSValue.jsNumber(value);
    return .ok;
}
pub export fn napi_create_int32(_: napi_env, value: i32, result: *napi_value) napi_status {
    result.* = JSValue.jsNumber(value);
    return .ok;
}
pub export fn napi_create_uint32(_: napi_env, value: u32, result: *napi_value) napi_status {
    result.* = JSValue.jsNumber(value);
    return .ok;
}
pub export fn napi_create_int64(_: napi_env, value: i64, result: *napi_value) napi_status {
    result.* = JSValue.jsNumber(value);
    return .ok;
}
pub export fn napi_create_string_latin1(env: napi_env, str: [*]const u8, length: usize, result: *napi_value) napi_status {
    var len = length;
    if (NAPI_AUTO_LENGTH == length) {
        len = bun.span(std.meta.assumeSentinel(str, 0)).len;
    }
    result.* = JSC.ZigString.init(str[0..len]).toValueGC(env);
    return .ok;
}
pub export fn napi_create_string_utf8(env: napi_env, str: [*]const u8, length: usize, result: *napi_value) napi_status {
    var len = length;
    if (NAPI_AUTO_LENGTH == length) {
        len = bun.span(std.meta.assumeSentinel(str, 0)).len;
    }
    result.* = JSC.ZigString.init(str[0..len]).withEncoding().toValueGC(env);
    return .ok;
}
pub export fn napi_create_string_utf16(env: napi_env, str: [*]const char16_t, length: usize, result: *napi_value) napi_status {
    var len = length;
    if (NAPI_AUTO_LENGTH == length) {
        len = bun.span(std.meta.assumeSentinel(str, 0)).len;
    }
    result.* = JSC.ZigString.from16(str, len).toValueGC(env);
    return .ok;
}
pub export fn napi_create_symbol(env: napi_env, description: napi_value, result: *napi_value) napi_status {
    var string_ref = JSC.C.JSValueToStringCopy(env.ref(), description.asObjectRef(), null);
    defer JSC.C.JSStringRelease(string_ref);
    result.* = JSValue.c(JSC.C.JSValueMakeSymbol(env.ref(), string_ref));
    return .ok;
}
pub export fn napi_create_error(env: napi_env, code: napi_value, msg: napi_value, result: *napi_value) napi_status {
    const system_error = JSC.SystemError{
        .code = if (!code.isEmptyOrUndefinedOrNull()) code.getZigString(env) else ZigString.Empty,
        .message = msg.getZigString(env),
    };
    result.* = system_error.toErrorInstance(env);
    return .ok;
}
pub extern fn napi_create_type_error(env: napi_env, code: napi_value, msg: napi_value, result: *napi_value) napi_status;
pub extern fn napi_create_range_error(env: napi_env, code: napi_value, msg: napi_value, result: *napi_value) napi_status;
pub export fn napi_typeof(env: napi_env, value: napi_value, result: *napi_valuetype) napi_status {
    if (value.isEmpty()) {
        result.* = .@"undefined";
        return .ok;
    }

    if (value.isUndefined()) {
        result.* = .@"undefined";
        return .ok;
    }

    if (value.isNull()) {
        result.* = .@"null";
        return .ok;
    }

    if (value.isBoolean()) {
        result.* = .boolean;
        return .ok;
    }

    if (value.isNumber()) {
        result.* = .number;
        return .ok;
    }

    if (value.isString()) {
        result.* = .string;
        return .ok;
    }

    if (value.isSymbol()) {
        result.* = .symbol;
        return .ok;
    }

    if (value.isBigInt()) {
        result.* = .bigint;
        return .ok;
    }

    if (value.isObject()) {
        if (value.isCallable(env.vm())) {
            result.* = .function;
            return .ok;
        }
        result.* = .object;
        return .ok;
    }

    if (value.isCell() and value.isCallable(env.vm())) {
        result.* = .function;
        return .ok;
    }

    return .invalid_arg;
}
pub export fn napi_get_value_double(_: napi_env, value: napi_value, result: *f64) napi_status {
    result.* = value.asNumber();
    return .ok;
}
pub export fn napi_get_value_int32(_: napi_env, value: napi_value, result: *i32) napi_status {
    result.* = value.to(i32);
    return .ok;
}
pub export fn napi_get_value_uint32(_: napi_env, value: napi_value, result: *u32) napi_status {
    result.* = value.to(u32);
    return .ok;
}
pub export fn napi_get_value_int64(_: napi_env, value: napi_value, result: *i64) napi_status {
    result.* = value.to(i64);
    return .ok;
}
pub export fn napi_get_value_bool(_: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = value.to(bool);
    return .ok;
}
inline fn maybeAppendNull(ptr: anytype, doit: bool) void {
    if (doit) {
        ptr.* = 0;
    }
}
pub export fn napi_get_value_string_latin1(env: napi_env, value: napi_value, buf_ptr: [*c]u8, bufsize: usize, result: *usize) napi_status {
    defer value.ensureStillAlive();
    const zig_str = value.getZigString(env);
    var buf = buf_ptr orelse {
        result.* = if (!zig_str.is16Bit())
            zig_str.len
        else
            // should be same length if valid latin1
            strings.elementLengthUTF16IntoUTF8([]const u16, zig_str.utf16SliceAligned());

        return .ok;
    };

    if (zig_str.len == 0) {
        result.* = 0;
        buf[0] = 0;

        return .ok;
    }

    var buf_ = buf[0..bufsize];

    if (bufsize == 0) {
        buf_ = bun.span(std.meta.assumeSentinel(buf_, 0));
        if (buf_.len == 0) {
            result.* = 0;
            return .ok;
        }
    }

    if (zig_str.is16Bit()) {
        const utf16 = zig_str.utf16SliceAligned();
        const wrote = JSC.WebCore.Encoder.writeU16(utf16.ptr, utf16.len, buf, buf_.len, .latin1);
        if (wrote < 0) {
            return .generic_failure;
        }
        maybeAppendNull(&buf[@intCast(usize, wrote)], bufsize == 0);
        // if zero terminated, report the length of the string without the null
        result.* = @intCast(@TypeOf(result.*), wrote);
        return .ok;
    }
    const to_copy = @minimum(zig_str.len, buf_.len);
    @memcpy(buf, zig_str.slice().ptr, to_copy);
    buf[to_copy] = 0;
    // if zero terminated, report the length of the string without the null
    result.* = to_copy;
    return .ok;
}

/// Copies a JavaScript string into a UTF-8 string buffer. The result is the
/// number of bytes (excluding the null terminator) copied into buf.
/// A sufficient buffer size should be greater than the length of string,
/// reserving space for null terminator.
/// If bufsize is insufficient, the string will be truncated and null terminated.
/// If buf is NULL, this method returns the length of the string (in bytes)
/// via the result parameter.
/// The result argument is optional unless buf is NULL.
pub export fn napi_get_value_string_utf8(env: napi_env, value: napi_value, buf_ptr: [*c]u8, bufsize: usize, result_ptr: ?*usize) napi_status {
    defer value.ensureStillAlive();
    if (!value.isString()) {
        return .string_expected;
    }

    const zig_str = value.getZigString(env);
    var buf = buf_ptr orelse {
        if (result_ptr) |result| {
            result.* = if (!zig_str.is16Bit())
                zig_str.len
            else
                JSC.WebCore.Encoder.byteLengthU16(zig_str.utf16SliceAligned().ptr, zig_str.utf16SliceAligned().len, .utf8);
        }

        return .ok;
    };

    if (zig_str.len == 0) {
        if (result_ptr) |result| {
            result.* = 0;
        }
        return .ok;
    }

    var buf_ = buf[0..bufsize];

    if (bufsize == 0) {
        buf_ = bun.span(std.meta.assumeSentinel(buf_, 0));
        if (buf_.len == 0) {
            if (result_ptr) |result| {
                result.* = 0;
            }
            return .ok;
        }
    }

    if (zig_str.is16Bit()) {
        const utf16 = zig_str.utf16SliceAligned();
        const wrote = JSC.WebCore.Encoder.writeU16(utf16.ptr, utf16.len, buf, buf_.len, .utf8);
        if (wrote < 0) {
            return .generic_failure;
        }
        buf[@intCast(usize, wrote)] = 0;
        if (result_ptr) |result| {
            result.* = @intCast(@TypeOf(result.*), wrote);
        }

        return .ok;
    }

    const to_copy = @minimum(zig_str.len, buf_.len);
    @memcpy(buf, zig_str.slice().ptr, to_copy);
    buf[to_copy] = 0;
    if (result_ptr) |result| {
        result.* = @intCast(@TypeOf(result.*), to_copy);
    }

    return .ok;
}
pub export fn napi_get_value_string_utf16(env: napi_env, value: napi_value, buf_ptr: [*c]char16_t, bufsize: usize, result_ptr: ?*usize) napi_status {
    defer value.ensureStillAlive();
    const zig_str = value.getZigString(env);
    var buf = buf_ptr orelse {
        if (result_ptr) |result| {
            result.* = if (zig_str.is16Bit())
                zig_str.len
            else
                JSC.WebCore.Encoder.byteLengthU16(zig_str.utf16SliceAligned().ptr, zig_str.utf16SliceAligned().len, .latin1);
        }

        return .ok;
    };

    if (zig_str.len == 0) {
        if (result_ptr) |result| {
            result.* = 0;
        }
        buf[0] = 0;

        return .ok;
    }

    var buf_ = buf[0..bufsize];

    if (bufsize == 0) {
        buf_ = bun.span(std.meta.assumeSentinel(buf_, 0));
        if (buf_.len == 0) {
            if (result_ptr) |result| {
                result.* = 0;
            }
            return .ok;
        }
    }

    if (!zig_str.is16Bit()) {
        const slice = zig_str.slice();
        const encode_into_result = strings.copyLatin1IntoUTF16([]char16_t, buf_, []const u8, slice);
        buf[@intCast(usize, encode_into_result.written)] = 0;

        if (result_ptr) |result| {
            result.* = encode_into_result.written;
        }
        return .ok;
    }

    const to_copy = @minimum(zig_str.len, buf_.len) * 2;
    @memcpy(std.mem.sliceAsBytes(buf_).ptr, std.mem.sliceAsBytes(zig_str.utf16SliceAligned()).ptr, to_copy);
    buf[to_copy] = 0;
    // if zero terminated, report the length of the string without the null
    if (result_ptr) |result| {
        result.* = to_copy;
    }

    return .ok;
}
pub export fn napi_coerce_to_bool(_: napi_env, value: napi_value, result: *napi_value) napi_status {
    result.* = JSValue.jsBoolean(value.to(bool));
    return .ok;
}
pub export fn napi_coerce_to_number(env: napi_env, value: napi_value, result: *napi_value) napi_status {
    result.* = JSC.JSValue.jsNumber(JSC.C.JSValueToNumber(env.ref(), value.asObjectRef(), TODO_EXCEPTION));
    return .ok;
}
pub export fn napi_coerce_to_object(env: napi_env, value: napi_value, result: *napi_value) napi_status {
    result.* = JSValue.c(JSC.C.JSValueToObject(env.ref(), value.asObjectRef(), TODO_EXCEPTION));
    return .ok;
}
pub export fn napi_get_prototype(env: napi_env, object: napi_value, result: *napi_value) napi_status {
    if (!object.isObject()) {
        return .object_expected;
    }

    result.* = JSValue.c(JSC.C.JSObjectGetPrototype(env.ref(), object.asObjectRef()));
    return .ok;
}
// TODO: bind JSC::ownKeys
// pub export fn napi_get_property_names(env: napi_env, object: napi_value, result: *napi_value) napi_status {
//     if (!object.isObject()) {
//         return .object_expected;
//     }

//     result.* =
// }
pub export fn napi_set_element(env: napi_env, object: napi_value, index: c_uint, value: napi_value) napi_status {
    if (!object.jsType().isIndexable()) {
        return .array_expected;
    }
    if (value.isEmpty())
        return .invalid_arg;
    JSC.C.JSObjectSetPropertyAtIndex(env.ref(), object.asObjectRef(), index, value.asObjectRef(), TODO_EXCEPTION);
    return .ok;
}
pub export fn napi_has_element(env: napi_env, object: napi_value, index: c_uint, result: *bool) napi_status {
    if (!object.jsType().isIndexable()) {
        return .array_expected;
    }

    result.* = object.getLengthOfArray(env) > index;
    return .ok;
}
pub export fn napi_get_element(env: napi_env, object: napi_value, index: u32, result: *napi_value) napi_status {
    if (!object.jsType().isIndexable()) {
        return .array_expected;
    }

    result.* = JSC.JSObject.getIndex(object, env, index);
    return .ok;
}
pub extern fn napi_define_properties(env: napi_env, object: napi_value, property_count: usize, properties: [*c]const napi_property_descriptor) napi_status;
pub export fn napi_is_array(_: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = value.jsType().isArray();
    return .ok;
}
pub export fn napi_get_array_length(env: napi_env, value: napi_value, result: [*c]u32) napi_status {
    if (!value.jsType().isArray()) {
        return .array_expected;
    }

    result.* = value.getLengthOfArray(env);
    return .ok;
}
pub export fn napi_strict_equals(env: napi_env, lhs: napi_value, rhs: napi_value, result: *bool) napi_status {
    // there is some nuance with NaN here i'm not sure about
    result.* = lhs.isSameValue(rhs, env);
    return .ok;
}
pub export fn napi_call_function(env: napi_env, recv: napi_value, func: napi_value, argc: usize, argv: [*c]const napi_value, result: *napi_value) napi_status {
    if (comptime JSC.is_bindgen) unreachable;
    var exception = [_]JSC.C.JSValueRef{null};
    result.* =
        JSC.C.JSObjectCallAsFunctionReturnValue(
        env.ref(),
        func.asObjectRef(),
        recv.asObjectRef(),
        argc,
        @ptrCast([*]const JSC.C.JSValueRef, argv),
    );
    if (exception[0] != null) {
        return .generic_failure;
    }

    return .ok;
}
pub export fn napi_new_instance(env: napi_env, constructor: napi_value, argc: usize, argv: [*c]const napi_value, result: *napi_value) napi_status {
    var exception = [_]JSC.C.JSValueRef{null};
    result.* = JSValue.c(
        JSC.C.JSObjectCallAsConstructor(
            env.ref(),
            constructor.asObjectRef(),
            argc,
            @ptrCast([*]const JSC.C.JSValueRef, argv),
            &exception,
        ),
    );
    if (exception[0] != null) {
        return .generic_failure;
    }

    return .ok;
}
pub export fn napi_instanceof(env: napi_env, object: napi_value, constructor: napi_value, result: *bool) napi_status {
    // TODO: does this throw object_expected in node?
    result.* = object.isInstanceOf(env, constructor);
    return .ok;
}
pub extern fn napi_get_cb_info(env: napi_env, cbinfo: napi_callback_info, argc: [*c]usize, argv: *napi_value, this_arg: *napi_value, data: [*]*anyopaque) napi_status;
pub extern fn napi_get_new_target(env: napi_env, cbinfo: napi_callback_info, result: *napi_value) napi_status;
pub extern fn napi_define_class(
    env: napi_env,
    utf8name: [*c]const u8,
    length: usize,
    constructor: napi_callback,
    data: ?*anyopaque,
    property_count: usize,
    properties: [*c]const napi_property_descriptor,
    result: *napi_value,
) napi_status;
pub extern fn napi_wrap(env: napi_env, js_object: napi_value, native_object: ?*anyopaque, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque, result: [*c]napi_ref) napi_status;
pub extern fn napi_unwrap(env: napi_env, js_object: napi_value, result: [*]*anyopaque) napi_status;
pub extern fn napi_remove_wrap(env: napi_env, js_object: napi_value, result: [*]*anyopaque) napi_status;
pub extern fn napi_create_external(env: napi_env, data: ?*anyopaque, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque, result: *napi_value) napi_status;
pub extern fn napi_get_value_external(env: napi_env, value: napi_value, result: [*]*anyopaque) napi_status;
pub extern fn napi_create_reference(env: napi_env, value: napi_value, initial_refcount: u32, result: [*c]napi_ref) napi_status;
pub extern fn napi_delete_reference(env: napi_env, ref: napi_ref) napi_status;
pub extern fn napi_reference_ref(env: napi_env, ref: napi_ref, result: [*c]u32) napi_status;
pub extern fn napi_reference_unref(env: napi_env, ref: napi_ref, result: [*c]u32) napi_status;
pub extern fn napi_get_reference_value(env: napi_env, ref: napi_ref, result: *napi_value) napi_status;

// JSC scans the stack
// we don't need this
pub export fn napi_open_handle_scope(env: napi_env, result: *napi_handle_scope) napi_status {
    result.* = env;
    return .ok;
}
// JSC scans the stack
// we don't need this
pub export fn napi_close_handle_scope(_: napi_env, _: napi_handle_scope) napi_status {
    return .ok;
}
pub extern fn napi_open_escapable_handle_scope(env: napi_env, result: [*c]napi_escapable_handle_scope) napi_status;
pub extern fn napi_close_escapable_handle_scope(env: napi_env, scope: napi_escapable_handle_scope) napi_status;
pub extern fn napi_escape_handle(env: napi_env, scope: napi_escapable_handle_scope, escapee: napi_value, result: *napi_value) napi_status;
pub extern fn napi_throw(env: napi_env, @"error": napi_value) napi_status;
pub extern fn napi_throw_error(env: napi_env, code: [*c]const u8, msg: [*c]const u8) napi_status;
pub extern fn napi_throw_type_error(env: napi_env, code: [*c]const u8, msg: [*c]const u8) napi_status;
pub extern fn napi_throw_range_error(env: napi_env, code: [*c]const u8, msg: [*c]const u8) napi_status;
pub export fn napi_is_error(env: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = value.isAnyError(env);
    return .ok;
}
pub extern fn napi_is_exception_pending(env: napi_env, result: *bool) napi_status;
pub extern fn napi_get_and_clear_last_exception(env: napi_env, result: *napi_value) napi_status;
pub export fn napi_is_arraybuffer(_: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = !value.isNumber() and value.jsTypeLoose() == .ArrayBuffer;
    return .ok;
}
pub export fn napi_create_arraybuffer(env: napi_env, byte_length: usize, data: [*]const u8, result: *napi_value) napi_status {
    var typed_array = JSC.C.JSObjectMakeTypedArray(env.ref(), .kJSTypedArrayTypeArrayBuffer, byte_length, TODO_EXCEPTION);
    var array_buffer = JSValue.c(typed_array).asArrayBuffer(env) orelse return .generic_failure;
    @memcpy(array_buffer.ptr, data, @minimum(array_buffer.len, @truncate(u32, byte_length)));
    result.* = JSValue.c(typed_array);
    return .ok;
}

pub export fn napi_create_external_arraybuffer(env: napi_env, external_data: ?*anyopaque, byte_length: usize, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque, result: *napi_value) napi_status {
    var external = JSC.ExternalBuffer.create(
        finalize_hint,
        @ptrCast([*]u8, external_data.?)[0..byte_length],
        env,
        finalize_cb,
        env.bunVM().allocator,
    ) catch {
        return .generic_failure;
    };
    result.* = external.toArrayBuffer(env);
    return .ok;
}
pub export fn napi_get_arraybuffer_info(env: napi_env, arraybuffer: napi_value, data: *[*]u8, byte_length: *usize) napi_status {
    const array_buffer = arraybuffer.asArrayBuffer(env) orelse return .arraybuffer_expected;
    var slice = array_buffer.slice();
    data.* = slice.ptr;
    byte_length.* = slice.len;
    return .ok;
}
pub export fn napi_is_typedarray(_: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = value.jsTypeLoose().isTypedArray();
    return .ok;
}
pub export fn napi_create_typedarray(env: napi_env, @"type": napi_typedarray_type, length: usize, arraybuffer: napi_value, byte_offset: usize, result: *napi_value) napi_status {
    result.* = JSValue.c(
        JSC.C.JSObjectMakeTypedArrayWithArrayBufferAndOffset(
            env.ref(),
            @"type".toC(),
            arraybuffer.asObjectRef(),
            byte_offset,
            length,
            TODO_EXCEPTION,
        ),
    );
    return .ok;
}
pub export fn napi_get_typedarray_info(
    env: napi_env,
    typedarray: napi_value,
    @"type": ?*napi_typedarray_type,
    length: ?*usize,
    data: ?*[*]u8,
    arraybuffer: ?*napi_value,
    byte_offset: ?*usize,
) napi_status {
    if (typedarray.isEmptyOrUndefinedOrNull())
        return .invalid_arg;
    defer typedarray.ensureStillAlive();

    const array_buffer = typedarray.asArrayBuffer(env) orelse return .invalid_arg;
    if (@"type" != null)
        @"type".?.* = napi_typedarray_type.fromJSType(array_buffer.typed_array_type) orelse return .invalid_arg;
    var slice = array_buffer.slice();

    if (data != null)
        data.?.* = slice.ptr;

    if (length != null)
        length.?.* = slice.len;

    if (arraybuffer != null)
        arraybuffer.?.* = JSValue.c(JSC.C.JSObjectGetTypedArrayBuffer(env.ref(), typedarray.asObjectRef(), null));

    if (byte_offset != null)
        byte_offset.?.* = array_buffer.offset;
    return .ok;
}
pub extern fn napi_create_dataview(env: napi_env, length: usize, arraybuffer: napi_value, byte_offset: usize, result: *napi_value) napi_status;
pub export fn napi_is_dataview(_: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = !value.isEmptyOrUndefinedOrNull() and value.jsTypeLoose() == .DataView;
    return .ok;
}
pub export fn napi_get_dataview_info(env: napi_env, dataview: napi_value, bytelength: *usize, data: *?[*]u8, arraybuffer: *napi_value, byte_offset: *usize) napi_status {
    var array_buffer = dataview.asArrayBuffer(env) orelse return .object_expected;
    bytelength.* = array_buffer.byte_len;
    data.* = array_buffer.ptr;
    // TODO: will this work? will it fail due to being a DataView instead of a TypedArray?
    arraybuffer.* = JSValue.c(JSC.C.JSObjectGetTypedArrayBuffer(env.ref(), dataview.asObjectRef(), null));
    byte_offset.* = array_buffer.offset;
    return .ok;
}
pub export fn napi_get_version(_: napi_env, result: *u32) napi_status {
    result.* = NAPI_VERSION;
    return .ok;
}
pub export fn napi_create_promise(env: napi_env, deferred: *napi_deferred, promise: *napi_value) napi_status {
    deferred.* = JSC.JSPromise.create(env);
    promise.* = deferred.*.asValue(env);
    return .ok;
}
pub export fn napi_resolve_deferred(env: napi_env, deferred: napi_deferred, resolution: napi_value) napi_status {
    deferred.resolve(env, resolution);
    return .ok;
}
pub export fn napi_reject_deferred(env: napi_env, deferred: napi_deferred, rejection: napi_value) napi_status {
    deferred.reject(env, rejection);
    return .ok;
}
pub export fn napi_is_promise(_: napi_env, value: napi_value, is_promise: *bool) napi_status {
    if (value.isEmptyOrUndefinedOrNull()) {
        is_promise.* = false;
        return .ok;
    }

    is_promise.* = value.asPromise() != null or value.asInternalPromise() != null;
    return .ok;
}
pub export fn napi_run_script(env: napi_env, script: napi_value, result: *napi_value) napi_status {
    // TODO: don't copy
    var ref = JSC.C.JSValueToStringCopy(env.ref(), script.asObjectRef(), TODO_EXCEPTION);
    defer JSC.C.JSStringRelease(ref);

    var exception = [_]JSC.C.JSValueRef{null};
    const val = JSC.C.JSEvaluateScript(env.ref(), ref, env.ref(), null, 0, &exception);
    if (exception[0] != null) {
        return .generic_failure;
    }

    result.* = JSValue.c(val);
    return .ok;
}
pub extern fn napi_adjust_external_memory(env: napi_env, change_in_bytes: i64, adjusted_value: [*c]i64) napi_status;
pub export fn napi_create_date(env: napi_env, time: f64, result: *napi_value) napi_status {
    var args = [_]JSC.C.JSValueRef{JSC.JSValue.jsNumber(time).asObjectRef()};
    result.* = JSValue.c(JSC.C.JSObjectMakeDate(env.ref(), 1, &args, TODO_EXCEPTION));
    return .ok;
}
pub export fn napi_is_date(_: napi_env, value: napi_value, is_date: *bool) napi_status {
    is_date.* = value.jsTypeLoose() == .JSDate;
    return .ok;
}
pub export fn napi_get_date_value(env: napi_env, value: napi_value, result: *f64) napi_status {
    const getTimeFunction = value.get(env, "getTime") orelse {
        return .date_expected;
    };

    result.* = JSValue.c(
        JSC.C.JSObjectCallAsFunction(env.ref(), getTimeFunction.asObjectRef(), value.asObjectRef(), 0, null, TODO_EXCEPTION),
    ).asNumber();
    return .ok;
}
pub extern fn napi_add_finalizer(env: napi_env, js_object: napi_value, native_object: ?*anyopaque, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque, result: *napi_ref) napi_status;
pub export fn napi_create_bigint_int64(env: napi_env, value: i64, result: *napi_value) napi_status {
    result.* = JSC.JSValue.fromInt64NoTruncate(env, value);
    return .ok;
}
pub export fn napi_create_bigint_uint64(env: napi_env, value: u64, result: *napi_value) napi_status {
    result.* = JSC.JSValue.fromUInt64NoTruncate(env, value);
    return .ok;
}
pub extern fn napi_create_bigint_words(env: napi_env, sign_bit: c_int, word_count: usize, words: [*c]const u64, result: *napi_value) napi_status;
// TODO: lossless
pub export fn napi_get_value_bigint_int64(_: napi_env, value: napi_value, result: *i64, _: *bool) napi_status {
    result.* = value.toInt64();
    return .ok;
}
// TODO: lossless
pub export fn napi_get_value_bigint_uint64(_: napi_env, value: napi_value, result: *u64, _: *bool) napi_status {
    result.* = value.toUInt64NoTruncate();
    return .ok;
}
pub extern fn napi_get_value_bigint_words(env: napi_env, value: napi_value, sign_bit: [*c]c_int, word_count: [*c]usize, words: [*c]u64) napi_status;
pub extern fn napi_get_all_property_names(env: napi_env, object: napi_value, key_mode: napi_key_collection_mode, key_filter: napi_key_filter, key_conversion: napi_key_conversion, result: *napi_value) napi_status;
pub extern fn napi_set_instance_data(env: napi_env, data: ?*anyopaque, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque) napi_status;
pub extern fn napi_get_instance_data(env: napi_env, data: [*]*anyopaque) napi_status;
pub extern fn napi_detach_arraybuffer(env: napi_env, arraybuffer: napi_value) napi_status;
pub extern fn napi_is_detached_arraybuffer(env: napi_env, value: napi_value, result: *bool) napi_status;
pub extern fn napi_type_tag_object(env: napi_env, value: napi_value, type_tag: [*c]const napi_type_tag) napi_status;
pub extern fn napi_check_object_type_tag(env: napi_env, value: napi_value, type_tag: [*c]const napi_type_tag, result: *bool) napi_status;
pub const struct_napi_async_work__ = opaque {};
const WorkPool = @import("../work_pool.zig").WorkPool;
const WorkPoolTask = @import("../work_pool.zig").Task;

/// must be globally allocated
pub const napi_async_work = struct {
    task: WorkPoolTask = .{ .callback = runFromThreadPool },
    completion_task: ?*anyopaque = null,
    event_loop: *JSC.EventLoop,
    global: napi_env,
    execute: napi_async_execute_callback = null,
    complete: napi_async_complete_callback = null,
    ctx: ?*anyopaque = null,
    status: std.atomic.Atomic(u32) = std.atomic.Atomic(u32).init(0),
    can_deinit: bool = false,
    wait_for_deinit: bool = false,
    scheduled: bool = false,
    pub const Status = enum(u32) {
        pending = 0,
        started = 1,
        completed = 2,
        cancelled = 3,
    };

    pub fn create(global: napi_env, execute: napi_async_execute_callback, complete: napi_async_complete_callback, ctx: ?*anyopaque) !*napi_async_work {
        var work = try bun.default_allocator.create(napi_async_work);
        work.* = .{
            .global = global,
            .execute = execute,
            .event_loop = global.bunVM().eventLoop(),
            .complete = complete,
            .ctx = ctx,
        };
        return work;
    }

    pub fn runFromThreadPool(task: *WorkPoolTask) void {
        var this = @fieldParentPtr(napi_async_work, "task", task);

        this.run();
    }
    pub fn run(this: *napi_async_work) void {
        if (this.status.compareAndSwap(@enumToInt(Status.pending), @enumToInt(Status.started), .SeqCst, .SeqCst)) |state| {
            if (state == @enumToInt(Status.cancelled)) {
                if (this.wait_for_deinit) {
                    // this might cause a segfault due to Task using a linked list!
                    bun.default_allocator.destroy(this);
                }
            }
            return;
        }
        this.execute.?(this.global, this.ctx);
        this.status.store(@enumToInt(Status.completed), .SeqCst);

        this.event_loop.enqueueTaskConcurrent(JSC.Task.init(this));
    }

    pub fn schedule(this: *napi_async_work) void {
        if (this.scheduled) return;
        this.scheduled = true;
        WorkPool.schedule(&this.task);
    }

    pub fn cancel(this: *napi_async_work) bool {
        return this.status.compareAndSwap(@enumToInt(Status.cancelled), @enumToInt(Status.pending), .SeqCst, .SeqCst) != null;
    }

    pub fn deinit(this: *napi_async_work) void {
        if (this.can_deinit) {
            bun.default_allocator.destroy(this);
            return;
        }
        this.wait_for_deinit = true;
    }

    pub fn runFromJS(this: *napi_async_work) void {
        this.complete.?(
            this.global,
            if (this.status.load(.SeqCst) == @enumToInt(Status.cancelled))
                napi_status.cancelled
            else
                napi_status.ok,
            this.ctx.?,
        );
    }
};
pub const napi_threadsafe_function = *ThreadSafeFunction;
pub const napi_threadsafe_function_release_mode = enum(c_uint) {
    release = 0,
    abort = 1,
};
pub const napi_tsfn_nonblocking = 0;
pub const napi_tsfn_blocking = 1;
pub const napi_threadsafe_function_call_mode = c_uint;
pub const napi_async_execute_callback = ?fn (napi_env, ?*anyopaque) callconv(.C) void;
pub const napi_async_complete_callback = ?fn (napi_env, napi_status, ?*anyopaque) callconv(.C) void;
pub const napi_threadsafe_function_call_js = fn (napi_env, napi_value, ?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const napi_node_version = extern struct {
    major: u32,
    minor: u32,
    patch: u32,
    release: [*c]const u8,

    pub const global: napi_node_version = .{
        .major = 17,
        .minor = 7,
        .patch = 17,
        .release = "Bun!!!",
    };
};
pub const struct_napi_async_cleanup_hook_handle__ = opaque {};
pub const napi_async_cleanup_hook_handle = ?*struct_napi_async_cleanup_hook_handle__;
pub const napi_async_cleanup_hook = ?fn (napi_async_cleanup_hook_handle, ?*anyopaque) callconv(.C) void;

pub const napi_addon_register_func = ?fn (napi_env, napi_value) callconv(.C) napi_value;
pub const struct_napi_module = extern struct {
    nm_version: c_int,
    nm_flags: c_uint,
    nm_filename: [*c]const u8,
    nm_register_func: napi_addon_register_func,
    nm_modname: [*c]const u8,
    nm_priv: ?*anyopaque,
    reserved: [4]?*anyopaque,
};
pub const napi_module = struct_napi_module;
fn napiSpan(ptr: anytype, len: usize) []const u8 {
    if (ptr == null)
        return &[_]u8{};

    if (len == NAPI_AUTO_LENGTH) {
        return std.mem.sliceTo(ptr.?, 0);
    }

    return ptr.?[0..len];
}
pub export fn napi_fatal_error(location_ptr: ?[*:0]const u8, location_len: usize, message_ptr: ?[*:0]const u8, message_len_: usize) noreturn {
    var message = napiSpan(message_ptr, message_len_);
    if (message.len == 0) {
        message = "fatal error";
    }

    const location = napiSpan(location_ptr, location_len);
    if (location.len > 0) {
        bun.Global.panic("napi: {s}\n  {s}", .{ message, location });
    }

    bun.Global.panic("napi: {s}", .{message});
}
pub export fn napi_create_buffer(env: napi_env, length: usize, data: [*]*anyopaque, result: *napi_value) napi_status {
    var buf = JSC.ExternalBuffer.create(null, @ptrCast([*]u8, data)[0..length], env, null, env.bunVM().allocator) catch {
        return .generic_failure;
    };

    result.* = buf.toJS(env);
    return .ok;
}
pub export fn napi_create_external_buffer(env: napi_env, length: usize, data: ?*anyopaque, finalize_cb: napi_finalize, finalize_hint: ?*anyopaque, result: *napi_value) napi_status {
    var buf = JSC.ExternalBuffer.create(finalize_hint, @ptrCast([*]u8, data.?)[0..length], env, finalize_cb, env.bunVM().allocator) catch {
        return .generic_failure;
    };

    result.* = buf.toJS(env);
    return .ok;
}
pub export fn napi_create_buffer_copy(env: napi_env, length: usize, data: [*]u8, result_data: ?*?*anyopaque, result: *napi_value) napi_status {
    var duped = env.bunVM().allocator.alloc(u8, length) catch {
        return .generic_failure;
    };
    @memcpy(duped.ptr, data, length);
    if (result_data) |res| {
        res.* = duped.ptr;
    }

    result.* = JSC.JSValue.createBuffer(env, duped, env.bunVM().allocator);

    return .ok;
}
pub export fn napi_is_buffer(env: napi_env, value: napi_value, result: *bool) napi_status {
    result.* = value.isBuffer(env);
    return .ok;
}
pub export fn napi_get_buffer_info(env: napi_env, value: napi_value, data: *[*]u8, length: *usize) napi_status {
    const array_buf = value.asArrayBuffer(env) orelse {
        // TODO: is invalid_arg what to return here?
        return .arraybuffer_expected;
    };

    data.* = array_buf.ptr;
    length.* = array_buf.byte_len;
    return .ok;
}
pub export fn napi_create_async_work(
    env: napi_env,
    _: napi_value,
    _: [*:0]const u8,
    execute: napi_async_execute_callback,
    complete: napi_async_complete_callback,
    data: ?*anyopaque,
    result: **napi_async_work,
) napi_status {
    result.* = napi_async_work.create(env, execute, complete, data) catch {
        return .generic_failure;
    };
    return .ok;
}
pub export fn napi_delete_async_work(env: napi_env, work: *napi_async_work) napi_status {
    std.debug.assert(env == work.global);
    work.deinit();
    return .ok;
}
pub export fn napi_queue_async_work(env: napi_env, work: *napi_async_work) napi_status {
    std.debug.assert(env == work.global);
    work.schedule();
    return .ok;
}
pub export fn napi_cancel_async_work(env: napi_env, work: *napi_async_work) napi_status {
    std.debug.assert(env == work.global);
    if (work.cancel()) {
        return .ok;
    }

    return napi_status.generic_failure;
}
pub export fn napi_get_node_version(_: napi_env, version: **const napi_node_version) napi_status {
    version.* = &napi_node_version.global;
    return .ok;
}
pub export fn napi_get_uv_event_loop(env: napi_env, loop: **JSC.EventLoop) napi_status {
    // lol
    loop.* = env.bunVM().eventLoop();
    return .ok;
}
pub extern fn napi_fatal_exception(env: napi_env, err: napi_value) napi_status;

// We use a linked list here because we assume removing these is relatively rare
// and array reallocations are relatively expensive.
pub export fn napi_add_env_cleanup_hook(env: napi_env, fun: ?fn (?*anyopaque) callconv(.C) void, arg: ?*anyopaque) napi_status {
    if (fun == null)
        return .ok;

    env.bunVM().rareData().pushCleanupHook(env, arg, fun.?);
    return .ok;
}
pub export fn napi_remove_env_cleanup_hook(env: napi_env, fun: ?fn (?*anyopaque) callconv(.C) void, arg: ?*anyopaque) napi_status {
    if (env.bunVM().rare_data == null or fun == null)
        return .ok;

    var rare_data = env.bunVM().rare_data.?;
    var hook = rare_data.cleanup_hook orelse return .ok;
    const cmp = JSC.RareData.CleanupHook.from(env, arg, fun.?);
    if (hook.eql(cmp)) {
        env.bunVM().allocator.destroy(hook);
        rare_data.cleanup_hook = null;
        rare_data.tail_cleanup_hook = null;
    }
    while (hook.next) |current| {
        if (hook.eql(cmp)) {
            if (current.next) |next| {
                hook.next = next;
            } else {
                hook.next = null;
            }
            env.bunVM().allocator.destroy(current);
            return .ok;
        }
        hook = current;
    }

    return .ok;
}

pub const Finalizer = struct {
    fun: napi_finalize,
    ctx: ?*anyopaque = null,
};

// TODO: generate comptime version of this instead of runtime checking
pub const ThreadSafeFunction = struct {
    /// thread-safe functions can be "referenced" and "unreferenced". A
    /// "referenced" thread-safe function will cause the event loop on the thread
    /// on which it is created to remain alive until the thread-safe function is
    /// destroyed. In contrast, an "unreferenced" thread-safe function will not
    /// prevent the event loop from exiting. The APIs napi_ref_threadsafe_function
    /// and napi_unref_threadsafe_function exist for this purpose.
    ///
    /// Neither does napi_unref_threadsafe_function mark the thread-safe
    /// functions as able to be destroyed nor does napi_ref_threadsafe_function
    /// prevent it from being destroyed.
    ref_for_process_exit: bool = false,

    owning_threads: std.AutoArrayHashMapUnmanaged(u64, void) = .{},
    owning_thread_lock: Lock = Lock.init(),
    event_loop: *JSC.EventLoop,

    javascript_function: JSValue,
    finalizer_task: JSC.AnyTask = undefined,
    finalizer: Finalizer = Finalizer{ .fun = null, .ctx = null },
    channel: Queue,

    ctx: ?*anyopaque = null,

    call_js: ?napi_threadsafe_function_call_js = null,

    const ThreadSafeFunctionTask = JSC.AnyTask.New(@This(), call);
    pub const Queue = union(enum) {
        sized: Channel(?*anyopaque, .Slice),
        unsized: Channel(?*anyopaque, .Dynamic),

        pub fn isClosed(this: *const @This()) bool {
            return @atomicLoad(
                bool,
                switch (this.*) {
                    .sized => &this.sized.is_closed,
                    .unsized => &this.unsized.is_closed,
                },
                .SeqCst,
            );
        }

        pub fn close(this: *@This()) void {
            switch (this.*) {
                .sized => this.sized.close(),
                .unsized => this.unsized.close(),
            }
        }

        pub fn init(size: usize, allocator: std.mem.Allocator) @This() {
            switch (size) {
                0 => {
                    return .{
                        .unsized = Channel(?*anyopaque, .Dynamic).init(allocator),
                    };
                },
                else => {
                    var slice = allocator.alloc(?*anyopaque, size) catch unreachable;
                    return .{
                        .sized = Channel(?*anyopaque, .Slice).init(slice),
                    };
                },
            }
        }

        pub fn writeItem(this: *@This(), value: ?*anyopaque) !void {
            switch (this.*) {
                .sized => try this.sized.writeItem(value),
                .unsized => try this.unsized.writeItem(value),
            }
        }

        pub fn readItem(this: *@This()) !?*anyopaque {
            return switch (this.*) {
                .sized => try this.sized.readItem(),
                .unsized => try this.unsized.readItem(),
            };
        }

        pub fn tryWriteItem(this: *@This(), value: ?*anyopaque) !bool {
            return switch (this.*) {
                .sized => try this.sized.tryWriteItem(value),
                .unsized => try this.unsized.tryWriteItem(value),
            };
        }

        pub fn tryReadItem(this: *@This()) !??*anyopaque {
            return switch (this.*) {
                .sized => try this.sized.tryReadItem(),
                .unsized => try this.unsized.tryReadItem(),
            };
        }
    };

    pub fn call(this: *ThreadSafeFunction) void {
        var task = this.channel.tryReadItem() catch null orelse return;
        if (this.call_js) |cb| {
            cb(this.event_loop.global, this.javascript_function, task, this.ctx);
        } else {
            // TODO: wrapper that reports errors
            _ = JSC.C.JSObjectCallAsFunction(
                this.event_loop.global.ref(),
                this.javascript_function.asObjectRef(),
                JSC.JSValue.jsUndefined().asObjectRef(),
                0,
                null,
                null,
            );
        }
    }

    pub fn enqueue(this: *ThreadSafeFunction, ctx: ?*anyopaque, block: bool) !void {
        if (block) {
            try this.channel.writeItem(ctx);
        } else {
            if (!try this.channel.tryWriteItem(ctx)) {
                return error.WouldBlock;
            }
        }

        this.event_loop.enqueueTaskConcurrent(JSC.Task.init(this));
    }

    pub fn finalize(opaq: *anyopaque) void {
        var this = bun.cast(*ThreadSafeFunction, opaq);
        if (this.finalizer.fun) |fun| {
            fun(this.event_loop.global, opaq, this.finalizer.ctx);
        }

        JSC.C.JSValueUnprotect(this.event_loop.global.ref(), this.javascript_function.asObjectRef());
        bun.default_allocator.destroy(this);
    }

    pub fn ref(this: *ThreadSafeFunction) void {
        this.ref_for_process_exit = true;
    }

    pub fn unref(this: *ThreadSafeFunction) void {
        this.ref_for_process_exit = false;
    }

    pub fn acquire(this: *ThreadSafeFunction) !void {
        this.owning_thread_lock.lock();
        defer this.owning_thread_lock.unlock();
        if (this.channel.isClosed())
            return error.Closed;
        _ = this.owning_threads.getOrPut(bun.default_allocator, std.Thread.getCurrentId()) catch unreachable;
    }

    pub fn release(this: *ThreadSafeFunction, mode: napi_threadsafe_function_release_mode) void {
        this.owning_thread_lock.lock();
        defer this.owning_thread_lock.unlock();
        if (!this.owning_threads.swapRemove(std.Thread.getCurrentId()))
            return;

        if (mode == .abort) {
            this.channel.close();
        }

        if (this.owning_threads.count() == 0) {
            this.finalizer_task = JSC.AnyTask{ .ctx = this, .callback = finalize };
            this.event_loop.enqueueTaskConcurrent(JSC.Task.init(&this.finalizer_task));
            return;
        }
    }
};

pub export fn napi_create_threadsafe_function(
    env: napi_env,
    func: napi_value,
    _: napi_value,
    _: napi_value,
    max_queue_size: usize,
    initial_thread_count: usize,
    thread_finalize_data: ?*anyopaque,
    thread_finalize_cb: napi_finalize,
    context: ?*anyopaque,
    call_js_cb: ?napi_threadsafe_function_call_js,
    result: *napi_threadsafe_function,
) napi_status {
    // TODO: don't do this
    // just have a GC hook for this...
    JSC.C.JSValueProtect(env.ref(), func.asObjectRef());
    var function = bun.default_allocator.create(ThreadSafeFunction) catch return .generic_failure;
    function.* = .{
        .event_loop = env.bunVM().eventLoop(),
        .javascript_function = func,
        .call_js = call_js_cb,
        .ctx = context,
        .channel = ThreadSafeFunction.Queue.init(max_queue_size, bun.default_allocator),
        .owning_threads = .{},
    };
    function.owning_threads.ensureTotalCapacity(bun.default_allocator, initial_thread_count) catch return .generic_failure;
    function.finalizer = .{ .ctx = thread_finalize_data, .fun = thread_finalize_cb };
    result.* = function;
    return .ok;
}
pub export fn napi_get_threadsafe_function_context(func: napi_threadsafe_function, result: *?*anyopaque) napi_status {
    result.* = func.ctx;
    return .ok;
}
pub export fn napi_call_threadsafe_function(func: napi_threadsafe_function, data: ?*anyopaque, is_blocking: napi_threadsafe_function_call_mode) napi_status {
    func.enqueue(data, is_blocking == napi_tsfn_blocking) catch |err| {
        switch (err) {
            error.WouldBlock => {
                return napi_status.queue_full;
            },

            else => return .closing,
        }
    };
    return .ok;
}
pub export fn napi_acquire_threadsafe_function(func: napi_threadsafe_function) napi_status {
    func.acquire() catch return .closing;
    return .ok;
}
pub export fn napi_release_threadsafe_function(func: napi_threadsafe_function, mode: napi_threadsafe_function_release_mode) napi_status {
    func.release(mode);
    return .ok;
}
pub export fn napi_unref_threadsafe_function(env: napi_env, func: napi_threadsafe_function) napi_status {
    std.debug.assert(func.event_loop.global == env);

    func.unref();
    return .ok;
}
pub export fn napi_ref_threadsafe_function(env: napi_env, func: napi_threadsafe_function) napi_status {
    std.debug.assert(func.event_loop.global == env);

    func.ref();
    return .ok;
}

pub export fn napi_add_async_cleanup_hook(_: napi_env, _: napi_async_cleanup_hook, _: ?*anyopaque, _: [*c]napi_async_cleanup_hook_handle) napi_status {
    // TODO:
    return .ok;
}
pub export fn napi_remove_async_cleanup_hook(_: napi_async_cleanup_hook_handle) napi_status {
    // TODO:
    return .ok;
}

pub const NAPI_VERSION_EXPERIMENTAL = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const NAPI_VERSION = @as(c_int, 8);
pub const NAPI_AUTO_LENGTH = std.math.maxInt(usize);
pub const SRC_NODE_API_TYPES_H_ = "";
pub const NAPI_MODULE_VERSION = @as(c_int, 1);

pub fn fixDeadCodeElimination() void {
    if (comptime JSC.is_bindgen) unreachable;
    std.mem.doNotOptimizeAway(&napi_get_undefined);
    std.mem.doNotOptimizeAway(&napi_get_null);
    std.mem.doNotOptimizeAway(&napi_get_boolean);
    std.mem.doNotOptimizeAway(&napi_create_object);
    std.mem.doNotOptimizeAway(&napi_create_array);
    std.mem.doNotOptimizeAway(&napi_create_array_with_length);
    std.mem.doNotOptimizeAway(&napi_create_double);
    std.mem.doNotOptimizeAway(&napi_create_int32);
    std.mem.doNotOptimizeAway(&napi_create_uint32);
    std.mem.doNotOptimizeAway(&napi_create_int64);
    std.mem.doNotOptimizeAway(&napi_create_string_latin1);
    std.mem.doNotOptimizeAway(&napi_create_string_utf8);
    std.mem.doNotOptimizeAway(&napi_create_string_utf16);
    std.mem.doNotOptimizeAway(&napi_create_symbol);
    std.mem.doNotOptimizeAway(&napi_create_error);
    std.mem.doNotOptimizeAway(&napi_typeof);
    std.mem.doNotOptimizeAway(&napi_get_value_double);
    std.mem.doNotOptimizeAway(&napi_get_value_int32);
    std.mem.doNotOptimizeAway(&napi_get_value_uint32);
    std.mem.doNotOptimizeAway(&napi_get_value_int64);
    std.mem.doNotOptimizeAway(&napi_get_value_bool);
    std.mem.doNotOptimizeAway(&napi_get_value_string_latin1);
    std.mem.doNotOptimizeAway(&napi_get_value_string_utf8);
    std.mem.doNotOptimizeAway(&napi_get_value_string_utf16);
    std.mem.doNotOptimizeAway(&napi_coerce_to_bool);
    std.mem.doNotOptimizeAway(&napi_coerce_to_number);
    std.mem.doNotOptimizeAway(&napi_coerce_to_object);
    // std.mem.doNotOptimizeAway(&napi_coerce_to_string);
    std.mem.doNotOptimizeAway(&napi_get_prototype);
    // std.mem.doNotOptimizeAway(&napi_get_property_names);
    std.mem.doNotOptimizeAway(&napi_set_element);
    std.mem.doNotOptimizeAway(&napi_has_element);
    std.mem.doNotOptimizeAway(&napi_get_element);
    // std.mem.doNotOptimizeAway(&napi_delete_element);
    std.mem.doNotOptimizeAway(&napi_is_array);
    std.mem.doNotOptimizeAway(&napi_get_array_length);
    std.mem.doNotOptimizeAway(&napi_strict_equals);
    std.mem.doNotOptimizeAway(&napi_call_function);
    std.mem.doNotOptimizeAway(&napi_new_instance);
    std.mem.doNotOptimizeAway(&napi_instanceof);
    std.mem.doNotOptimizeAway(&napi_open_handle_scope);
    std.mem.doNotOptimizeAway(&napi_close_handle_scope);
    std.mem.doNotOptimizeAway(&napi_is_error);
    std.mem.doNotOptimizeAway(&napi_is_arraybuffer);
    std.mem.doNotOptimizeAway(&napi_create_arraybuffer);
    std.mem.doNotOptimizeAway(&napi_create_external_arraybuffer);
    std.mem.doNotOptimizeAway(&napi_get_arraybuffer_info);
    std.mem.doNotOptimizeAway(&napi_is_typedarray);
    std.mem.doNotOptimizeAway(&napi_create_typedarray);
    std.mem.doNotOptimizeAway(&napi_get_typedarray_info);
    std.mem.doNotOptimizeAway(&napi_is_dataview);
    std.mem.doNotOptimizeAway(&napi_get_dataview_info);
    std.mem.doNotOptimizeAway(&napi_get_version);
    std.mem.doNotOptimizeAway(&napi_create_promise);
    std.mem.doNotOptimizeAway(&napi_resolve_deferred);
    std.mem.doNotOptimizeAway(&napi_reject_deferred);
    std.mem.doNotOptimizeAway(&napi_is_promise);
    std.mem.doNotOptimizeAway(&napi_run_script);
    std.mem.doNotOptimizeAway(&napi_create_date);
    std.mem.doNotOptimizeAway(&napi_is_date);
    std.mem.doNotOptimizeAway(&napi_get_date_value);
    std.mem.doNotOptimizeAway(&napi_create_bigint_int64);
    std.mem.doNotOptimizeAway(&napi_create_bigint_uint64);
    std.mem.doNotOptimizeAway(&napi_get_value_bigint_int64);
    std.mem.doNotOptimizeAway(&napi_get_value_bigint_uint64);
    std.mem.doNotOptimizeAway(&napi_fatal_error);
    std.mem.doNotOptimizeAway(&napi_create_buffer);
    std.mem.doNotOptimizeAway(&napi_create_external_buffer);
    std.mem.doNotOptimizeAway(&napi_create_buffer_copy);
    std.mem.doNotOptimizeAway(&napi_is_buffer);
    std.mem.doNotOptimizeAway(&napi_get_buffer_info);
    std.mem.doNotOptimizeAway(&napi_create_async_work);
    std.mem.doNotOptimizeAway(&napi_delete_async_work);
    std.mem.doNotOptimizeAway(&napi_queue_async_work);
    std.mem.doNotOptimizeAway(&napi_cancel_async_work);
    std.mem.doNotOptimizeAway(&napi_get_node_version);
    std.mem.doNotOptimizeAway(&napi_get_uv_event_loop);
    std.mem.doNotOptimizeAway(&napi_add_env_cleanup_hook);
    std.mem.doNotOptimizeAway(&napi_remove_env_cleanup_hook);
    std.mem.doNotOptimizeAway(&napi_create_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_get_threadsafe_function_context);
    std.mem.doNotOptimizeAway(&napi_call_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_acquire_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_release_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_unref_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_ref_threadsafe_function);
    std.mem.doNotOptimizeAway(&napi_add_async_cleanup_hook);
    std.mem.doNotOptimizeAway(&napi_remove_async_cleanup_hook);
    std.mem.doNotOptimizeAway(&napi_add_finalizer);

    std.mem.doNotOptimizeAway(&@import("../bun.js/node/buffer.zig").BufferVectorized.fill);
}

comptime {
    if (!JSC.is_bindgen) {
        _ = napi_get_undefined;
        _ = napi_get_null;
        _ = napi_get_boolean;
        _ = napi_create_object;
        _ = napi_create_array;
        _ = napi_create_array_with_length;
        _ = napi_create_double;
        _ = napi_create_int32;
        _ = napi_create_uint32;
        _ = napi_create_int64;
        _ = napi_create_string_latin1;
        _ = napi_create_string_utf8;
        _ = napi_create_string_utf16;
        _ = napi_create_symbol;
        _ = napi_create_error;
        _ = napi_typeof;
        _ = napi_get_value_double;
        _ = napi_get_value_int32;
        _ = napi_get_value_uint32;
        _ = napi_get_value_int64;
        _ = napi_get_value_bool;
        _ = napi_get_value_string_latin1;
        _ = napi_get_value_string_utf8;
        _ = napi_get_value_string_utf16;
        _ = napi_coerce_to_bool;
        _ = napi_coerce_to_number;
        _ = napi_coerce_to_object;
        _ = napi_get_prototype;

        _ = napi_set_element;
        _ = napi_has_element;
        _ = napi_get_element;
        _ = napi_is_array;
        _ = napi_get_array_length;
        _ = napi_strict_equals;
        _ = napi_call_function;
        _ = napi_new_instance;
        _ = napi_instanceof;
        _ = napi_open_handle_scope;
        _ = napi_close_handle_scope;
        _ = napi_is_error;
        _ = napi_is_arraybuffer;
        _ = napi_create_arraybuffer;
        _ = napi_create_external_arraybuffer;
        _ = napi_get_arraybuffer_info;
        _ = napi_is_typedarray;
        _ = napi_create_typedarray;
        _ = napi_get_typedarray_info;
        _ = napi_is_dataview;
        _ = napi_get_dataview_info;
        _ = napi_get_version;
        _ = napi_create_promise;
        _ = napi_resolve_deferred;
        _ = napi_reject_deferred;
        _ = napi_is_promise;
        _ = napi_run_script;
        _ = napi_create_date;
        _ = napi_is_date;
        _ = napi_get_date_value;
        _ = napi_create_bigint_int64;
        _ = napi_create_bigint_uint64;
        _ = napi_get_value_bigint_int64;
        _ = napi_get_value_bigint_uint64;
        _ = napi_fatal_error;
        _ = napi_create_buffer;
        _ = napi_create_external_buffer;
        _ = napi_create_buffer_copy;
        _ = napi_is_buffer;
        _ = napi_get_buffer_info;
        _ = napi_create_async_work;
        _ = napi_delete_async_work;
        _ = napi_queue_async_work;
        _ = napi_cancel_async_work;
        _ = napi_get_node_version;
        _ = napi_get_uv_event_loop;
        _ = napi_add_env_cleanup_hook;
        _ = napi_remove_env_cleanup_hook;
        _ = napi_create_threadsafe_function;
        _ = napi_get_threadsafe_function_context;
        _ = napi_call_threadsafe_function;
        _ = napi_acquire_threadsafe_function;
        _ = napi_release_threadsafe_function;
        _ = napi_unref_threadsafe_function;
        _ = napi_ref_threadsafe_function;
        _ = napi_add_async_cleanup_hook;
        _ = napi_remove_async_cleanup_hook;
        _ = @import("../bun.js/node/buffer.zig").BufferVectorized.fill;
        _ = napi_add_finalizer;
    }
}
