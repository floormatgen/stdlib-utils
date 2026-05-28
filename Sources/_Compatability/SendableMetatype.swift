#if swift(>=6.2)
@_documentation(visibility: internal)
public typealias _SendableMetatype = SendableMetatype
#else
@_documentation(visibility: internal)
public typealias _SendableMetatype = Any
#endif

#if swift(>=6.2)
@_documentation(visibility: internal)
public typealias _NonEscapable = ~Escapable
#else
@_documentation(visibility: internal)
public typealias _NonEscapable = Any
#endif
