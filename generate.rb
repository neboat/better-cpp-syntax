require 'json'
require_relative './readable_regex.rb'


$adjectives = [
    :isOperator,
    :isWordish,
    :isOperatorAlias,
    :canAppearAfterOperatorKeyword,
    :isPostFixOperator,
    :isPreFixOperator,
    :isInFixOperator,
    :evaledLeftToRight,
    :evaledRightToLeft,
    :presedence,
    :isControlFlow,
    :isLogicicalOperator,
    :isAssignmentOperator,
    :isComparisionOperator,
    :isUrnaryOperator,
    :isBinaryOperator,
    :isTernaryOperator,
    :requiresParentheseBlockImmediately,
    :isExceptionRelated,
    :isPrimitive,
    :isNotPrimitive,
    :isType,
    :isNotType,
    :isLiteral,
    :isTypeCreator,
    :isGenericTypeModifier,
    :isLeftHandSideTypeModifier,
    :isSpecifier,
    :isLambdaSpecifier,
    :isAccessSpecifier,
]

$tokens = [
    # operators
    { representation: "::"                   , name: "scope-resolution"               , isOperator: true,                                      isBinaryOperator:  true, presedence:  1   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "++"                   , name: "post-increment"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  2.1 , evaledLeftToRight: true, isPostFixOperator: true },
    { representation: "--"                   , name: "post-decrement"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  2.1 , evaledLeftToRight: true, isPostFixOperator: true },
    { representation: "()"                   , name: "function-call"                  , isOperator: true, canAppearAfterOperatorKeyword: true,                          presedence:  2.3 , evaledLeftToRight: true,                         },
    { representation: "[]"                   , name: "subscript"                      , isOperator: true, canAppearAfterOperatorKeyword: true,                          presedence:  2.4 , evaledLeftToRight: true,                         },
    { representation: "."                    , name: "object-accessor"                , isOperator: true,                                      isBinaryOperator:  true, presedence:  2.5 , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "->"                   , name: "pointer-accessor"               , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  2.5 , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "++"                   , name: "pre-increment"                  , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.1 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "--"                   , name: "pre-decrement"                  , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.1 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "+"                    , name: "plus"                           , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.2 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "-"                    , name: "minus"                          , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.2 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "!"                    , name: "logic-not"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isLogicicalOperator: true },
    { representation: "not"                  , name: "logic-not-word"                 , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isLogicicalOperator: true, isOperatorAlias: true },
    { representation: "~"                    , name: "bitwise-not"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "compl"                , name: "bitwise-not-word"               , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isOperatorAlias: true},
    { representation: "*"                    , name: "dereference"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.5 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "&"                    , name: "address-of"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.6 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "sizeof"               , name: "sizeof"                         , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.7 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "sizeof..."            , name: "variadic-sizeof"                , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.7 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "new"                  , name: "new"                            , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.8 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "new[]"                , name: "new-array"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.8 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "delete"               , name: "delete"                         , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.9 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "delete[]"             , name: "delete-array"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.9 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: ".*"                   , name: "object-accessor-dereference"    , isOperator: true,                                      isBinaryOperator:  true, presedence:  4   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "->*"                  , name: "pointer-accessor-dereference"   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  4   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "*"                    , name: "multiplication"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "/"                    , name: "division"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "%"                    , name: "modulus"                        , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "+"                    , name: "addition"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  6   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "-"                    , name: "subtraction"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  6   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "<<"                   , name: "bitwise-shift-left"             , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  7   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: ">>"                   , name: "bitwise-shift-right"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  7   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "<=>"                  , name: "three-way-compare"              , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  8   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "<"                    , name: "less-than"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.1 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "<="                   , name: "less-than-or-equal-to"          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.1 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: ">"                    , name: "greater-than"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.2 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: ">="                   , name: "greater-than-or-equal-to"       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.2 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "=="                   , name: "equal-to"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "!="                   , name: "not-equal-to"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "not_eq"               , name: "not-equal-to-word"              , isOperator: true,                                      isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true, isOperatorAlias: true,},
    { representation: "&"                    , name: "bitwise-and"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 11   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "bitand"               , name: "bitwise-and-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 11   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "^"                    , name: "bitwise-xor"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "xor"                  , name: "bitwise-xor-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "|"                    , name: "bitwise-or"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 13   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "bitor"                , name: "bitwise-or-word"                , isOperator: true,                                      isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "&&"                   , name: "logical-and"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 14   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true},
    { representation: "and"                  , name: "logical-and-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 14   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true, isOperatorAlias: true},
    { representation: "||"                   , name: "logical-or"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 15   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true},
    { representation: "or"                   , name: "logical-or-word"                , isOperator: true,                                      isBinaryOperator:  true, presedence: 15   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true, isOperatorAlias: true},
    { representation: "?:"                   , name: "ternary-conditional"            , isOperator: true,                                      isTernaryOperator: true, presedence: 16.1 , evaledRightToLeft: true,                         },
    { representation: "throw"                , name: "throw"                          , isOperator: true,                                      isUrnaryOperator:  true, presedence: 16.2 , evaledRightToLeft: true, isPreFixOperator:  true , isControlFlow: true, isExceptionRelated: true},
    { representation: "="                    , name: "direct-assignment"              , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.3 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "+="                   , name: "addition-assignment"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.4 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "-="                   , name: "subtraction-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.4 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "*="                   , name: "multiplication-assignment"      , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "/="                   , name: "division-assignment"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "%="                   , name: "modulus-assignment"             , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "<<="                  , name: "bitwise-shift-left-assignment"  , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.6 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: ">>="                  , name: "bitwise-shift-right-assignment" , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.6 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "&="                   , name: "bitwise-and-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "and_eq"               , name: "bitwise-and-assignment-word"    , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: "^="                   , name: "bitwise-xor-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "xor_eq"               , name: "bitwise-xor-assignment-word"    , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: "|="                   , name: "bitwise-or-assignment"          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "or_eq"                , name: "bitwise-or-assignment-word"     , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: ","                    , name: "comma"                          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true },
    # no presedence
    { representation: "alignof"              , name: "alignof"                        , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "alignas"              , name: "alignas"                        , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "typeid"               , name: "typeid"                         , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "noexcept"             , name: "noexcept"                       , isOperator: true },
    { representation: "static_cast"          , name: "static_cast"                    , isOperator: true },
    { representation: "dynamic_cast"         , name: "dynamic_cast"                   , isOperator: true },
    { representation: "const_cast"           , name: "const_cast"                     , isOperator: true },
    { representation: "reinterpret_cast"     , name: "reinterpret_cast"               , isOperator: true },
    # control
    { representation: "while"                , name: "while"                          , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "for"                  , name: "for"                            , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "do"                   , name: "do"                             , isControlFlow: true,                                           },
    { representation: "if"                   , name: "if"                             , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "else"                 , name: "else"                           , isControlFlow: true,                                           },
    { representation: "goto"                 , name: "goto"                           , isControlFlow: true,                                           },
    { representation: "switch"               , name: "switch"                         , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "try"                  , name: "try"                            , isControlFlow: true,                                           isExceptionRelated: true},
    { representation: "catch"                , name: "catch"                          , isControlFlow: true, requiresParentheseBlockImmediately: true, isExceptionRelated: true},
    { representation: "return"               , name: "return"                         , isControlFlow: true,                                           },
    { representation: "break"                , name: "break"                          , isControlFlow: true,                                           isExceptionRelated: true},
    { representation: "case"                 , name: "case"                           , isControlFlow: true,                                           isExceptionRelated: true},
    { representation: "continue"             , name: "continue"                       , isControlFlow: true,                                           isExceptionRelated: true},
    { representation: "default"              , name: "default"                        , isControlFlow: true,                                           isExceptionRelated: true},
    # primitive type keywords
    { representation: "auto"                 , name: "auto"                           , isPrimitive: true, isType: true},
    { representation: "void"                 , name: "void"                           , isPrimitive: true, isType: true},
    { representation: "char"                 , name: "char"                           , isPrimitive: true, isType: true},
    { representation: "short"                , name: "short"                          , isPrimitive: true, isType: true},
    { representation: "int"                  , name: "int"                            , isPrimitive: true, isType: true},
    { representation: "signed"               , name: "signed"                         , isPrimitive: true, isType: true},
    { representation: "unsigned"             , name: "unsigned"                       , isPrimitive: true, isType: true},
    { representation: "long"                 , name: "long"                           , isPrimitive: true, isType: true},
    { representation: "float"                , name: "float"                          , isPrimitive: true, isType: true},
    { representation: "double"               , name: "double"                         , isPrimitive: true, isType: true},
    { representation: "bool"                 , name: "bool"                           , isPrimitive: true, isType: true},
    { representation: "wchar_t"              , name: "wchar_t"                        , isPrimitive: true, isType: true},
    # other types
    { representation: "u_char"               , name: "u_char"               , isType: true },
    { representation: "u_short"              , name: "u_short"              , isType: true },
    { representation: "u_int"                , name: "u_int"                , isType: true },
    { representation: "u_long"               , name: "u_long"               , isType: true },
    { representation: "ushort"               , name: "ushort"               , isType: true },
    { representation: "uint"                 , name: "uint"                 , isType: true },
    { representation: "u_quad_t"             , name: "u_quad_t"             , isType: true },
    { representation: "quad_t"               , name: "quad_t"               , isType: true },
    { representation: "qaddr_t"              , name: "qaddr_t"              , isType: true },
    { representation: "caddr_t"              , name: "caddr_t"              , isType: true },
    { representation: "daddr_t"              , name: "daddr_t"              , isType: true },
    { representation: "div_t"                , name: "div_t"                , isType: true },
    { representation: "dev_t"                , name: "dev_t"                , isType: true },
    { representation: "fixpt_t"              , name: "fixpt_t"              , isType: true },
    { representation: "blkcnt_t"             , name: "blkcnt_t"             , isType: true },
    { representation: "blksize_t"            , name: "blksize_t"            , isType: true },
    { representation: "gid_t"                , name: "gid_t"                , isType: true },
    { representation: "in_addr_t"            , name: "in_addr_t"            , isType: true },
    { representation: "in_port_t"            , name: "in_port_t"            , isType: true },
    { representation: "ino_t"                , name: "ino_t"                , isType: true },
    { representation: "key_t"                , name: "key_t"                , isType: true },
    { representation: "mode_t"               , name: "mode_t"               , isType: true },
    { representation: "nlink_t"              , name: "nlink_t"              , isType: true },
    { representation: "id_t"                 , name: "id_t"                 , isType: true },
    { representation: "pid_t"                , name: "pid_t"                , isType: true },
    { representation: "off_t"                , name: "off_t"                , isType: true },
    { representation: "segsz_t"              , name: "segsz_t"              , isType: true },
    { representation: "swblk_t"              , name: "swblk_t"              , isType: true },
    { representation: "uid_t"                , name: "uid_t"                , isType: true },
    { representation: "id_t"                 , name: "id_t"                 , isType: true },
    { representation: "clock_t"              , name: "clock_t"              , isType: true },
    { representation: "size_t"               , name: "size_t"               , isType: true },
    { representation: "ssize_t"              , name: "ssize_t"              , isType: true },
    { representation: "time_t"               , name: "time_t"               , isType: true },
    { representation: "useconds_t"           , name: "useconds_t"           , isType: true },
    { representation: "suseconds_t"          , name: "suseconds_t"          , isType: true },
    { representation: "pthread_attr_t"       , name: "pthread_attr_t"       , isType: true },
    { representation: "pthread_cond_t"       , name: "pthread_cond_t"       , isType: true },
    { representation: "pthread_condattr_t"   , name: "pthread_condattr_t"   , isType: true },
    { representation: "pthread_mutex_t"      , name: "pthread_mutex_t"      , isType: true },
    { representation: "pthread_mutexattr_t"  , name: "pthread_mutexattr_t"  , isType: true },
    { representation: "pthread_once_t"       , name: "pthread_once_t"       , isType: true },
    { representation: "pthread_rwlock_t"     , name: "pthread_rwlock_t"     , isType: true },
    { representation: "pthread_rwlockattr_t" , name: "pthread_rwlockattr_t" , isType: true },
    { representation: "pthread_t"            , name: "pthread_t"            , isType: true },
    { representation: "pthread_key_t"        , name: "pthread_key_t"        , isType: true },
    { representation: "int8_t"               , name: "int8_t"               , isType: true },
    { representation: "int16_t"              , name: "int16_t"              , isType: true },
    { representation: "int32_t"              , name: "int32_t"              , isType: true },
    { representation: "int64_t"              , name: "int64_t"              , isType: true },
    { representation: "uint8_t"              , name: "uint8_t"              , isType: true },
    { representation: "uint16_t"             , name: "uint16_t"             , isType: true },
    { representation: "uint32_t"             , name: "uint32_t"             , isType: true },
    { representation: "uint64_t"             , name: "uint64_t"             , isType: true },
    { representation: "int_least8_t"         , name: "int_least8_t"         , isType: true },
    { representation: "int_least16_t"        , name: "int_least16_t"        , isType: true },
    { representation: "int_least32_t"        , name: "int_least32_t"        , isType: true },
    { representation: "int_least64_t"        , name: "int_least64_t"        , isType: true },
    { representation: "uint_least8_t"        , name: "uint_least8_t"        , isType: true },
    { representation: "uint_least16_t"       , name: "uint_least16_t"       , isType: true },
    { representation: "uint_least32_t"       , name: "uint_least32_t"       , isType: true },
    { representation: "uint_least64_t"       , name: "uint_least64_t"       , isType: true },
    { representation: "int_fast8_t"          , name: "int_fast8_t"          , isType: true },
    { representation: "int_fast16_t"         , name: "int_fast16_t"         , isType: true },
    { representation: "int_fast32_t"         , name: "int_fast32_t"         , isType: true },
    { representation: "int_fast64_t"         , name: "int_fast64_t"         , isType: true },
    { representation: "uint_fast8_t"         , name: "uint_fast8_t"         , isType: true },
    { representation: "uint_fast16_t"        , name: "uint_fast16_t"        , isType: true },
    { representation: "uint_fast32_t"        , name: "uint_fast32_t"        , isType: true },
    { representation: "uint_fast64_t"        , name: "uint_fast64_t"        , isType: true },
    { representation: "intptr_t"             , name: "intptr_t"             , isType: true },
    { representation: "uintptr_t"            , name: "uintptr_t"            , isType: true },
    { representation: "intmax_t"             , name: "intmax_t"             , isType: true },
    { representation: "intmax_t"             , name: "intmax_t"             , isType: true },
    { representation: "uintmax_t"            , name: "uintmax_t"            , isType: true },
    { representation: "uintmax_t"            , name: "uintmax_t"            , isType: true },
    # type modifiers
    { representation: "const"                , name: "const"            , isGenericTypeModifier: true },
    { representation: "static"               , name: "static"           , isGenericTypeModifier: true },
    { representation: "volatile"             , name: "volatile"         , isGenericTypeModifier: true },
    { representation: "register"             , name: "register"         , isGenericTypeModifier: true },
    { representation: "restrict"             , name: "restrict"         , isGenericTypeModifier: true },
    { representation: "constexpr"            , name: "constexpr"        , isLeftHandSideTypeModifier: true },
    { representation: "extern"               , name: "extern"           , isLeftHandSideTypeModifier: true },
    { representation: "inline"               , name: "inline"           , isLeftHandSideTypeModifier: true },
    { representation: "mutable"              , name: "mutable"          , isLeftHandSideTypeModifier: true },
    { representation: "friend"               , name: "friend"           , isLeftHandSideTypeModifier: true },
    # literals
    { representation: "NULL"                 , name: "NULL"             , isLiteral: true },
    { representation: "true"                 , name: "true"             , isLiteral: true },
    { representation: "false"                , name: "false"            , isLiteral: true },
    { representation: "nullptr"              , name: "nullptr"          , isLiteral: true },
    # type creators
    { representation: "class"                , name: "class"           , isTypeCreator: true},
    { representation: "struct"               , name: "struct"          , isTypeCreator: true},
    { representation: "union"                , name: "union"           , isTypeCreator: true},
    { representation: "enum"                 , name: "enum"            , isTypeCreator: true},
    # specifiers
    { representation: "explicit"             , name: "explicit"         , isSpecifier: true },
    { representation: "virtual"              , name: "virtual"          , isSpecifier: true },
    # lambda specifiers
    { representation: "mutable"                , name: "mutable"            , isLambdaSpecifier: true },
    { representation: "constexpr"              , name: "constexpr"          , isLambdaSpecifier: true },
    { representation: "consteval"              , name: "consteval"          , isLambdaSpecifier: true },
    # accessor
    { representation: "private"               , name: "private"             , isAccessSpecifier: true },
    { representation: "protected"             , name: "protected"           , isAccessSpecifier: true },
    { representation: "public"                , name: "public"              , isAccessSpecifier: true },
    # pre processor directives
    { representation: "if"                    , name: "if"                     , isPreprocessorDirective: true },
    { representation: "elif"                  , name: "elif"                   , isPreprocessorDirective: true },
    { representation: "else"                  , name: "else"                   , isPreprocessorDirective: true },
    { representation: "endif"                 , name: "endif"                  , isPreprocessorDirective: true },
    { representation: "ifdef"                 , name: "ifdef"                  , isPreprocessorDirective: true },
    { representation: "ifndef"                , name: "ifndef"                 , isPreprocessorDirective: true },
    { representation: "define"                , name: "define"                 , isPreprocessorDirective: true },
    { representation: "undef"                 , name: "undef"                  , isPreprocessorDirective: true },
    { representation: "include"               , name: "include"                , isPreprocessorDirective: true },
    { representation: "line"                  , name: "line"                   , isPreprocessorDirective: true },
    { representation: "error"                 , name: "error"                  , isPreprocessorDirective: true },
    { representation: "warning"               , name: "warning"                , isPreprocessorDirective: true },
    { representation: "pragma"                , name: "pragma"                 , isPreprocessorDirective: true },
    { representation: "_Pragma"               , name: "pragma"                 , isPreprocessorDirective: true },
    { representation: "defined"               , name: "defined"                , isPreprocessorDirective: true },
    { representation: "__has_include"         , name: "__has_include"          , isPreprocessorDirective: true },
    { representation: "__has_cpp_attribute"   , name: "__has_cpp_attribute"    , isPreprocessorDirective: true },
    # 
    # misc
    # 
    { representation: "this"            , name: "this"          },
    { representation: "template"        , name: "template"      },
    { representation: "namespace"       , name: "namespace"     },
    { representation: "using"           , name: "using"         },
    { representation: "operator"        , name: "operator"      },
    # 
    { representation: "typedef"         , name: "typedef"       },
    { representation: "decltype"        , name: "decltype"      },
    { representation: "typename"        , name: "typename"      },
    # 
    { representation: "asm"                        , name: "asm"                        },
    { representation: "__asm__"                    , name: "__asm__"                    },
    # 
    { representation: "atomic_cancel"              , name: "atomic_cancel"              },
    { representation: "atomic_commit"              , name: "atomic_commit"              },
    { representation: "atomic_noexcept"            , name: "atomic_noexcept"            },
    { representation: "concept"                    , name: "concept"                    },
    { representation: "co_await"                   , name: "co_await"                   },
    { representation: "co_return"                  , name: "co_return"                  },
    { representation: "co_yield"                   , name: "co_yield"                   },
    { representation: "export"                     , name: "export"                     },
    { representation: "import"                     , name: "import"                     },
    { representation: "module"                     , name: "module"                     },
    { representation: "reflexpr"                   , name: "reflexpr"                   },
    { representation: "requires"                   , name: "requires"                   },
    { representation: "synchronized"               , name: "synchronized"               },
    { representation: "thread_local"               , name: "thread_local"               },
    # 
    { representation: "audit"                      , name: "audit"                      },
    { representation: "axiom"                      , name: "axiom"                      },
    { representation: "transaction_safe"           , name: "transaction_safe"           },
    { representation: "transaction_safe_dynamic"   , name: "transaction_safe_dynamic"   },
]

# 
# attach adjectives
# 
for each in $tokens
    # isSymbol, isWordish
    if each[:representation] =~ /[a-zA-Z0-9_]/
        each[:isWordish] = true
    else
        each[:isSymbol] = true
    end
    # isWord
    if each[:representation] =~ /\A[a-zA-Z_][a-zA-Z0-9_]*\z/
        each[:isWord] = true
    end
    # isNotType
    if each[:isType] != true
        each[:isNotType] = true
    end
    # isNotPrimitive
    if each[:isPrimitive] != true and each[:isType] == true
        each[:isNotPrimitive] = true
    end
    # isPreprocessorDirective
    if each[:isPreprocessorDirective] != true
        each[:isNotPreprocessorDirective] = true
    end
end


# todo
    # fix initializer list "functions"
    # replace all strings with regex literals
    # add adjectives:
        # canHaveBrackets
        # mustHaveBrackets
        # canBeModifier
        # canHaveParaentheses
        # canBeOnRightHandSide
        # cantHaveParaentheses
        # cannotBeFunctionName
        # cannotBeVariableName
    # have all patterns with keywords be dynamically generated
    # lambda -> 
    # operator with words/space
    # add user-defined constants variable.other.constant.user-defined.cpp

# Edgecases to remember
    # ... inside of catch()
    # operator overload for user-defined literal 
    # labels for goto
    # lambda syntax
#
# Helpers
#
def anyTokenThat(*arguments)
    matches = $tokens.select do |each_token|
        output = true
        for each_adjective in arguments
            if each_token[each_adjective] != true
                output = false
                break
            end
        end
        output
    end
    return /(?:(?:#{matches.map {|each| Regexp.escape(each[:representation]) }.join("|")}))/
end



# type modifiers
with_reference   = maybe(@spaces).then(  /&/.or /&&/  ).maybe(@spaces)
with_dereference = maybe(@spaces).zeroOrMoreOf( /\*/  ).maybe(@spaces)

# misc
builtin_c99_function_names = /(_Exit|(?:nearbyint|nextafter|nexttoward|netoward|nan)[fl]?|a(?:cos|sin)h?[fl]?|abort|abs|asctime|assert|atan(?:[h2]?[fl]?)?|atexit|ato[ifl]|atoll|bsearch|btowc|cabs[fl]?|cacos|cacos[fl]|cacosh[fl]?|calloc|carg[fl]?|casinh?[fl]?|catanh?[fl]?|cbrt[fl]?|ccosh?[fl]?|ceil[fl]?|cexp[fl]?|cimag[fl]?|clearerr|clock|clog[fl]?|conj[fl]?|copysign[fl]?|cosh?[fl]?|cpow[fl]?|cproj[fl]?|creal[fl]?|csinh?[fl]?|csqrt[fl]?|ctanh?[fl]?|ctime|difftime|div|erfc?[fl]?|exit|fabs[fl]?|exp(?:2[fl]?|[fl]|m1[fl]?)?|fclose|fdim[fl]?|fe[gs]et(?:env|exceptflag|round)|feclearexcept|feholdexcept|feof|feraiseexcept|ferror|fetestexcept|feupdateenv|fflush|fgetpos|fgetw?[sc]|floor[fl]?|fmax?[fl]?|fmin[fl]?|fmod[fl]?|fopen|fpclassify|fprintf|fputw?[sc]|fread|free|freopen|frexp[fl]?|fscanf|fseek|fsetpos|ftell|fwide|fwprintf|fwrite|fwscanf|genv|get[sc]|getchar|gmtime|gwc|gwchar|hypot[fl]?|ilogb[fl]?|imaxabs|imaxdiv|isalnum|isalpha|isblank|iscntrl|isdigit|isfinite|isgraph|isgreater|isgreaterequal|isinf|isless(?:equal|greater)?|isw?lower|isnan|isnormal|isw?print|isw?punct|isw?space|isunordered|isw?upper|iswalnum|iswalpha|iswblank|iswcntrl|iswctype|iswdigit|iswgraph|isw?xdigit|labs|ldexp[fl]?|ldiv|lgamma[fl]?|llabs|lldiv|llrint[fl]?|llround[fl]?|localeconv|localtime|log[2b]?[fl]?|log1[p0][fl]?|longjmp|lrint[fl]?|lround[fl]?|malloc|mbr?len|mbr?towc|mbsinit|mbsrtowcs|mbstowcs|memchr|memcmp|memcpy|memmove|memset|mktime|modf[fl]?|perror|pow[fl]?|printf|puts|putw?c(?:har)?|qsort|raise|rand|remainder[fl]?|realloc|remove|remquo[fl]?|rename|rewind|rint[fl]?|round[fl]?|scalbl?n[fl]?|scanf|setbuf|setjmp|setlocale|setvbuf|signal|signbit|sinh?[fl]?|snprintf|sprintf|sqrt[fl]?|srand|sscanf|strcat|strchr|strcmp|strcoll|strcpy|strcspn|strerror|strftime|strlen|strncat|strncmp|strncpy|strpbrk|strrchr|strspn|strstr|strto[kdf]|strtoimax|strtol[dl]?|strtoull?|strtoumax|strxfrm|swprintf|swscanf|system|tan|tan[fl]|tanh[fl]?|tgamma[fl]?|time|tmpfile|tmpnam|tolower|toupper|trunc[fl]?|ungetw?c|va_arg|va_copy|va_end|va_start|vfw?printf|vfw?scanf|vprintf|vscanf|vsnprintf|vsprintf|vsscanf|vswprintf|vswscanf|vwprintf|vwscanf|wcrtomb|wcscat|wcschr|wcscmp|wcscoll|wcscpy|wcscspn|wcsftime|wcslen|wcsncat|wcsncmp|wcsncpy|wcspbrk|wcsrchr|wcsrtombs|wcsspn|wcsstr|wcsto[dkf]|wcstoimax|wcstol[dl]?|wcstombs|wcstoull?|wcstoumax|wcsxfrm|wctom?b|wmem(?:set|chr|cpy|cmp|move)|wprintf|wscanf)/

# 
# variable
# 
character_in_variable_name = /[a-zA-Z0-9_]/
# todo: make a better name for this function
variableBounds = ->(regex_pattern) do
    lookBehindToAvoid(character_in_variable_name).then(regex_pattern).lookAheadToAvoid(character_in_variable_name)
end
variable_name_without_bounds = /[a-zA-Z_]#{-character_in_variable_name}*/
# word bounds are inefficient, but they are accurate
variable_name = variableBounds[variable_name_without_bounds]

# 
# Constants
# 
builtin_constants_1_group = variableBounds[newGroup(anyTokenThat(:isLiteral))]
probably_user_constant_1_group = variableBounds[lookAheadToAvoid(anyTokenThat(:isWord)).then(newGroup(/[A-Z][_A-Z]*/))]
constants_pattern_2_groups = builtin_constants_1_group.or(probably_user_constant_1_group)

# 
# Scope resolution
#
                characters_in_template_call = /[\s<>,\w]/
            template_call_match = /</.zeroOrMoreOf(characters_in_template_call).then(/>/).maybe(@spaces)
        one_scope_resolution = variable_name_without_bounds.maybe(@spaces).maybe(template_call_match).then(/::/)
    preceding_scopes_1_group = newGroup(zeroOrMoreOf(one_scope_resolution))
maybe_scope_resoleved_variable_2_groups = preceding_scopes_1_group.then(newGroup(variable_name_without_bounds)).then(@word_boundary)
preceding_scopes_4_groups = preceding_scopes_1_group.then(newGroup(variable_name_without_bounds).maybe(@spaces).maybe(newGroup(template_call_match))).then(newGroup(/::/))


# 
# types
# 
    symbols_that_can_appear_after_a_type = /[&*>\]\)]/
look_behind_for_type = lookBehindFor(character_in_variable_name.and(@space).or(symbols_that_can_appear_after_a_type)).maybe(@spaces)
primitive_types = lookBehindToAvoid(character_in_variable_name).then(anyTokenThat(:isPrimitive)).lookAheadToAvoid(character_in_variable_name)
non_primitive_types = lookBehindToAvoid(character_in_variable_name).then(anyTokenThat(:isNotPrimitive)).lookAheadToAvoid(character_in_variable_name)
known_types = lookBehindToAvoid(character_in_variable_name).then(anyTokenThat(:isType)).lookAheadToAvoid(character_in_variable_name)
posix_reserved_types =  variableBounds[  /[a-zA-Z_]/.zeroOrMoreOf(character_in_variable_name).then(/_t/)  ]

# 
# Probably a parameter
#
            array_brackets = /\[\]/.maybe(@spaces)
            comma_or_closing_paraenthese = /,/.or(/\)/)
        stuff_after_a_parameter = maybe(@spaces).lookAheadFor(maybe(array_brackets).then(comma_or_closing_paraenthese))
    probably_a_normal_parameter_1_group = look_behind_for_type.then(newGroup(variable_name_without_bounds)).then(stuff_after_a_parameter)
    # below uses variable_name_without_bounds for performance (timeout) reasons
    probably_a_default_parameter_1_group = newGroup(variable_name_without_bounds).maybe(@spaces).lookAheadFor("=")
probably_a_parameter_2_groups = probably_a_default_parameter_1_group.or(probably_a_normal_parameter_1_group)


# 
# operator overload
# 
        # symbols can have spaces
        operator_symbols = maybe(@spaces).then(anyTokenThat(:canAppearAfterOperatorKeyword, :isSymbol))
        # words must have spaces, the variable_name_without_bounds is for implicit overloads
        operator_wordish = @spaces.then(anyTokenThat(:canAppearAfterOperatorKeyword, :isWordish).or(zeroOrMoreOf(one_scope_resolution).then(variable_name_without_bounds).maybe(@spaces).maybe(/&/)))
    after_operator_keyword = operator_symbols.or(operator_wordish)
operator_overload_4_groups = preceding_scopes_1_group.then(newGroup(/operator/)).then(newGroup(after_operator_keyword)).maybe(@spaces).then(newGroup(/\(/))

# 
# Access member . .* -> ->* 
#
    before_the_access_operator_1_group = newGroup(variable_name_without_bounds).or(lookBehindFor(/\]|\)/)).maybe(@spaces)
    member_operator_2_groups = newGroup(/\./.or(/\.\*/)).or(newGroup(/->/.or(/->\*/))).maybe(@spaces)
        subsequent_object_with_operator = variable_name_without_bounds.maybe(@spaces).then(/\./.or(/->/)).maybe(@spaces)
    subsequent_members_1_group = newGroup(zeroOrMoreOf(subsequent_object_with_operator))
    # try to avoid matching types to help with this not matching during lambda functions
    final_memeber_1_group = @word_boundary.lookAheadToAvoid(anyTokenThat(:isType)).then(newGroup(variable_name_without_bounds)).then(@word_boundary).lookAheadToAvoid(/\(/)
member_pattern_5_groups = before_the_access_operator_1_group.then(member_operator_2_groups).then(subsequent_members_1_group).then(final_memeber_1_group)

# 
# Functions
# 
        cant_be_a_function_name = anyTokenThat(:isWord, :isNotPreprocessorDirective)
        # this next line needs to be updated (its legacy)
        probably_intended_scope_resolve = /(?:[A-Za-z_][A-Za-z0-9_]*+|::)++/
    avoid_keywords = lookBehindToAvoid(character_in_variable_name).lookAheadToAvoid(cant_be_a_function_name.maybe(@spaces).then(/\(/))
    look_ahead_for_function_name = lookAheadFor(variable_name_without_bounds.maybe(@spaces).then(/\(/))
function_definition_pattern = avoid_keywords.then(look_ahead_for_function_name)

# 
# Namespace
# 
namespace_pattern_2_groups = @word_boundary.then(newGroup(/namespace/)).maybe(@spaces).thenNewGroup(zeroOrMoreOf(one_scope_resolution).then(variable_name_without_bounds))

# 
# preprocessor
#
    # not sure if this pattern is actually accurate (it was the one provided by atom/c.tmLanguage)
    preprocessor_name_no_bounds = /[a-zA-Z_$][\w$]*/
preprocessor_function_name = preprocessor_name_no_bounds.lookAheadFor(maybe(@spaces).then(/\(/))

cpp_grammar = {
    information_for_contributors: [
        "This code was auto generated by a much-more-readble ruby file: https://github.com/jeff-hykin/cpp-textmate-grammar/blob/master/generate.rb",
        "It is a lot easier to modify the ruby file and have it generate the rest of the code",
        "Also the ruby source is very open to merge requests, so please make one if something could be improved",
        "This file essentially an updated/improved fork of the atom syntax https://github.com/atom/language-c/blob/master/grammars/c%2B%2B.cson",
    ],
    version: "https://github.com/jeff-hykin/cpp-textmate-grammar/blob/master/generate.rb",
    name: "C++",
    scopeName: "source.cpp",
    patterns: [
        {
            include: "#special_block"
        },
        {
            include: "#strings"
        },
        {
            match: -/\b(typedef|friend|explicit|virtual|override|final|noexcept)\b/,
            name: "storage.modifier.cpp"
        },
        {
            match: -/\b(private:|protected:|public:)/,
            name: "storage.type.modifier.access.cpp"
        },
        {
            match: -/\b(catch|try|throw|using)\b/,
            name: "keyword.control.cpp"
        },
        {
            match: -/\bdelete\b(\s*\[\])?|\bnew\b(?!\])/,
            name: "keyword.control.cpp"
        },
        {
            match: -/\b(f|m)[A-Z]\w*\b/,
            name: "variable.other.readwrite.member.cpp"
        },
        {
            match: -/\bthis\b/,
            name: "variable.language.this.cpp"
        },
        {
            include: "#constants"
        },
        {
            include: "#template_definition"
        },
        {
            match: -/\btemplate\b\s*/,
            name: "storage.type.template.cpp"
        },
        {
            match: -/\b(const_cast|dynamic_cast|reinterpret_cast|static_cast)\b\s*/,
            name: "keyword.operator.cast.cpp"
        },
        {
            include: "#scope_resolution"
        },
        {
            match: -/\b(and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)\b/,
            name: "keyword.operator.cpp"
        },
        {
            match: -/\b(decltype|wchar_t|char16_t|char32_t)\b/,
            name: "storage.type.cpp"
        },
        {
            match: -/\b(constexpr|export|mutable|typename|thread_local)\b/,
            name: "storage.modifier.cpp"
        },
        {
            begin: "(?x)\n(?:\n  ^ |                  # beginning of line\n  (?:(?<!else|new|=))  # or word + space before name\n)\n((?:[A-Za-z_][A-Za-z0-9_]*::)*+~[A-Za-z_][A-Za-z0-9_]*) # actual name\n\\s*(\\()              # opening bracket",
            beginCaptures: {
                "1" => {
                    name: "entity.name.function.cpp"
                },
                "2" => {
                    name: "punctuation.definition.parameters.begin.c"
                }
            },
            end: -/\)/,
            endCaptures: {
                "0" => {
                    name: "punctuation.definition.parameters.end.c"
                }
            },
            name: "meta.function.destructor.cpp",
            patterns: [
                {
                    include: "$base"
                }
            ]
        },
        {
            begin: "(?x)\n(?:\n  ^ |                  # beginning of line\n  (?:(?<!else|new|=))  # or word + space before name\n)\n((?:[A-Za-z_][A-Za-z0-9_]*::)*+~[A-Za-z_][A-Za-z0-9_]*) # actual name\n\\s*(\\()              # opening bracket",
            beginCaptures: {
                "1" => {
                    name: "entity.name.function.cpp"
                },
                "2" => {
                    name: "punctuation.definition.parameters.begin.c"
                }
            },
            end: -/\)/,
            endCaptures: {
                "0" => {
                    name: "punctuation.definition.parameters.end.c"
                }
            },
            name: "meta.function.destructor.prototype.cpp",
            patterns: [
                {
                    include: "$base"
                }
            ]
        },
        # 
        # C patterns
        # 
        {
            include: "#preprocessor-rule-enabled"
        },
        {
            include: "#preprocessor-rule-disabled"
        },
        {
            include: "#preprocessor-rule-conditional"
        },
        {
            include: "#comments-c"
        },
        {
            match: "\\b(break|case|continue|default|do|else|for|goto|if|_Pragma|return|switch|while)\\b",
            name: "keyword.control.c"
        },
        {
            include: "#storage_types-c"
        },
        {
            match: "\\b(const|extern|register|restrict|static|volatile|inline)\\b",
            name: "storage.modifier.c"
        },
        {
            match: "\\bk[A-Z]\\w*\\b",
            name: "constant.other.variable.mac-classic.c"
        },
        {
            match: "\\bg[A-Z]\\w*\\b",
            name: "variable.other.readwrite.global.mac-classic.c"
        },
        {
            match: "\\bs[A-Z]\\w*\\b",
            name: "variable.other.readwrite.static.mac-classic.c"
        },
        {
            include: "#operators-c"
        },
        {
            include: "#operator_overload"
        },
        {
            include: "#numbers-c"
        },
        {
            include: "#strings-c"
        },
        {
            begin: "(?x)\n^\\s* ((\\#)\\s*define) \\s+\t# define\n((?<id>#{-preprocessor_name_no_bounds}))\t  # macro name\n(?:\n  (\\()\n\t(\n\t  \\s* \\g<id> \\s*\t\t # first argument\n\t  ((,) \\s* \\g<id> \\s*)*  # additional arguments\n\t  (?:\\.\\.\\.)?\t\t\t# varargs ellipsis?\n\t)\n  (\\))\n)?",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.define.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                },
                "3" => {
                    name: "entity.name.function.preprocessor.c"
                },
                "5" => {
                    name: "punctuation.definition.parameters.begin.c"
                },
                "6" => {
                    name: "variable.parameter.preprocessor.c"
                },
                "8" => {
                    name: "punctuation.separator.parameters.c"
                },
                "9" => {
                    name: "punctuation.definition.parameters.end.c"
                }
            },
            end: "(?=(?://|/\\*))|(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.macro.c",
            patterns: [
                {
                    include: "#preprocessor-rule-define-line-contents"
                }
            ]
        },
        {
            begin: "^\\s*((#)\\s*(error|warning))\\b\\s*",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.diagnostic.$3.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.diagnostic.c",
            patterns: [
                {
                    begin: "\"",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "\"|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.double.c",
                    patterns: [
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                },
                {
                    begin: "'",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "'|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.single.c",
                    patterns: [
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                },
                {
                    begin: "[^'\"]",
                    end: "(?<!\\\\)(?=\\s*\\n)",
                    name: "string.unquoted.single.c",
                    patterns: [
                        {
                            include: "#line_continuation_character"
                        },
                        {
                            include: "#comments-c"
                        }
                    ]
                }
            ]
        },
        {
            begin: "^\\s*((#)\\s*(include(?:_next)?|import))\\b\\s*",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.$3.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=(?://|/\\*))|(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.include.c",
            patterns: [
                {
                    include: "#line_continuation_character"
                },
                {
                    begin: "\"",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "\"",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.double.include.c"
                },
                {
                    begin: "<",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: ">",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.other.lt-gt.include.c"
                }
            ]
        },
        {
            include: "#pragma-mark"
        },
        {
            begin: "^\\s*((#)\\s*line)\\b",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.line.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=(?://|/\\*))|(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.c",
            patterns: [
                {
                    include: "#strings-c"
                },
                {
                    include: "#numbers-c"
                },
                {
                    include: "#line_continuation_character"
                }
            ]
        },
        {
            begin: "^\\s*(?:((#)\\s*undef))\\b",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.undef.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=(?://|/\\*))|(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.c",
            patterns: [
                {
                    match: -preprocessor_name_no_bounds,
                    name: "entity.name.function.preprocessor.c"
                },
                {
                    include: "#line_continuation_character"
                }
            ]
        },
        {
            begin: "^\\s*(?:((#)\\s*pragma))\\b",
            beginCaptures: {
                "1" => {
                    name: "keyword.control.directive.pragma.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=(?://|/\\*))|(?<!\\\\)(?=\\n)",
            name: "meta.preprocessor.pragma.c",
            patterns: [
                {
                    include: "#strings-c"
                },
                {
                    match: "[a-zA-Z_$][\\w\\-$]*",
                    name: "entity.other.attribute-name.pragma.preprocessor.c"
                },
                {
                    include: "#numbers-c"
                },
                {
                    include: "#line_continuation_character"
                }
            ]
        },
        {
            match: "\\b(u_char|u_short|u_int|u_long|ushort|uint|u_quad_t|quad_t|qaddr_t|caddr_t|daddr_t|div_t|dev_t|fixpt_t|blkcnt_t|blksize_t|gid_t|in_addr_t|in_port_t|ino_t|key_t|mode_t|nlink_t|id_t|pid_t|off_t|segsz_t|swblk_t|uid_t|id_t|clock_t|size_t|ssize_t|time_t|useconds_t|suseconds_t)\\b",
            name: "support.type.sys-types.c"
        },
        {
            match: "\\b(pthread_attr_t|pthread_cond_t|pthread_condattr_t|pthread_mutex_t|pthread_mutexattr_t|pthread_once_t|pthread_rwlock_t|pthread_rwlockattr_t|pthread_t|pthread_key_t)\\b",
            name: "support.type.pthread.c"
        },
        {
            match: "(?x) \\b\n(int8_t|int16_t|int32_t|int64_t|uint8_t|uint16_t|uint32_t|uint64_t|int_least8_t\n|int_least16_t|int_least32_t|int_least64_t|uint_least8_t|uint_least16_t|uint_least32_t\n|uint_least64_t|int_fast8_t|int_fast16_t|int_fast32_t|int_fast64_t|uint_fast8_t\n|uint_fast16_t|uint_fast32_t|uint_fast64_t|intptr_t|uintptr_t|intmax_t|intmax_t\n|uintmax_t|uintmax_t)\n\\b",
            name: "support.type.stdint.c"
        },
        {
            match: "\\b(noErr|kNilOptions|kInvalidID|kVariableLengthArray)\\b",
            name: "support.constant.mac-classic.c"
        },
        {
            match: "(?x) \\b\n(AbsoluteTime|Boolean|Byte|ByteCount|ByteOffset|BytePtr|CompTimeValue|ConstLogicalAddress|ConstStrFileNameParam\n|ConstStringPtr|Duration|Fixed|FixedPtr|Float32|Float32Point|Float64|Float80|Float96|FourCharCode|Fract|FractPtr\n|Handle|ItemCount|LogicalAddress|OptionBits|OSErr|OSStatus|OSType|OSTypePtr|PhysicalAddress|ProcessSerialNumber\n|ProcessSerialNumberPtr|ProcHandle|Ptr|ResType|ResTypePtr|ShortFixed|ShortFixedPtr|SignedByte|SInt16|SInt32|SInt64\n|SInt8|Size|StrFileName|StringHandle|StringPtr|TimeBase|TimeRecord|TimeScale|TimeValue|TimeValue64|UInt16|UInt32\n|UInt64|UInt8|UniChar|UniCharCount|UniCharCountPtr|UniCharPtr|UnicodeScalarValue|UniversalProcHandle|UniversalProcPtr\n|UnsignedFixed|UnsignedFixedPtr|UnsignedWide|UTF16Char|UTF32Char|UTF8Char)\n\\b",
            name: "support.type.mac-classic.c"
        },
        {
            match: -posix_reserved_types,
            name: "support.type.posix-reserved.c"
        },
        {
            include: "#block-c"
        },
        {
            include: "#parens-c"
        },
        {
            begin: -function_definition_pattern,
            end: -lookBehindFor(/\)/), # old pattern: "(?<=\\))(?!\\w)",
            name: "meta.function.definition.c",
            patterns: [
                {
                    include: "#function-innards-c"
                }
            ]
        },
        {
            include: "#line_continuation_character"
        },
        {
            name: "meta.bracket.square.access.c",
            begin: "([a-zA-Z_][a-zA-Z_0-9]*|(?<=[\\]\\)]))?(\\[)(?!\\])",
            beginCaptures: {
                "1" => {
                    name: "variable.object.c"
                },
                "2" => {
                    name: "punctuation.definition.begin.bracket.square.c"
                }
            },
            end: "\\]",
            endCaptures: {
                "0" => {
                    name: "punctuation.definition.end.bracket.square.c"
                }
            },
            patterns: [
                {
                    include: "#function-call-innards-c"
                }
            ]
        },
        {
            name: "storage.modifier.array.bracket.square.c",
            match: "\\[\\s*\\]"
        },
        {
            match: ";",
            name: "punctuation.terminator.statement.c"
        },
        {
            match: ",",
            name: "punctuation.separator.delimiter.c"
        }
    ],
    repository: {
        "template-call-innards" => {
            name: "meta.template.call.cpp",
            match: -template_call_match,
            captures: {
                "0" => {
                    patterns: [
                        {
                            include: "#storage_types-c",
                        },
                        {
                            include: "#constants",
                        },
                        {
                            include: "#scope_resolution",
                        },
                        {
                            match: -variable_name,
                            name: "storage.type.user-defined.cpp",
                        },
                        {
                            include: "#operators-c"
                        },
                        {
                            include: "#numbers-c"
                        },
                        {
                            include: "#strings"
                        },
                    ]
                }
            }
        },
        "constants" => {
            match: -builtin_constants_1_group,
            name: "constant.cpp",
            captures: {
                "1" => {
                    name: "constant.language.built-in.$1.cpp"
                },
            }
        },
        "scope_resolution" => {
            name: "punctuation.separator.namespace.access.cpp",
            match: -preceding_scopes_4_groups,
            captures: {
                "1" => {
                    name: "entity.scope.c",
                    patterns: [
                        {
                            include: "#scope_resolution"
                        }
                    ]
                },
                "2" => {
                    name: "entity.scope.name.c"
                },
                "3" => {
                    patterns: [
                        {
                            include: "#template-call-innards"
                        }
                    ]
                },
                "4" => {
                    name: "punctuation.separator.namespace.access.cpp"
                }
            }
        },
        "template_definition" => {
            begin: "\\b(template)\\s*(<)\\s*",
            beginCaptures: {
                "1" => {
                    name: "storage.type.template.cpp"
                },
                "2" => {
                    name: "punctuation.section.angle-brackets.start.template.definition.cpp"
                }
            },
            end: ">",
            endCaptures: {
                "0" => {
                    name: "punctuation.section.angle-brackets.end.template.definition.cpp"
                }
            },
            name: "template.definition",
            patterns: [
                {
                    include: "#template_definition_argument"
                }
            ]
        },
        "template_definition_argument" => {
            match: "\\s*(?:([a-zA-Z_][a-zA-Z_0-9]*\\s*)|((?:[a-zA-Z_][a-zA-Z_0-9]*\\s+)*)([a-zA-Z_][a-zA-Z_0-9]*)|([a-zA-Z_][a-zA-Z_0-9]*)\\s*(\\.\\.\\.)\\s*([a-zA-Z_][a-zA-Z_0-9]*)|((?:[a-zA-Z_][a-zA-Z_0-9]*\\s+)*)([a-zA-Z_][a-zA-Z_0-9]*)\\s*(=)\\s*(\\w+))(,|(?=>))",
            captures: {
                "1" => {
                    name: "storage.type.template.cpp"
                },
                "2" => {
                    name: "storage.type.template.cpp"
                },
                "3" => {
                    name: "entity.name.type.template.cpp"
                },
                "4" => {
                    name: "storage.type.template.cpp"
                },
                "5" => {
                    name: "meta.template.operator.ellipsis"
                },
                "6" => {
                    name: "entity.name.type.template.cpp"
                },
                "7" => {
                    name: "storage.type.template.cpp"
                },
                "8" => {
                    name: "entity.name.type.template.cpp"
                },
                "9" => {
                    name: "keyword.operator.assignment.c"
                },
                "10" => {
                    name: "constant.language.cpp"
                },
                "11" => {
                    name: "meta.template.operator.comma.cpp"
                }
            }
        },
        "angle_brackets" => {
            begin: "<",
            end: ">",
            name: "meta.angle-brackets.cpp",
            patterns: [
                {
                    include: "#angle_brackets"
                },
                {
                    include: "$base"
                }
            ]
        },
        "block" => {
            begin: "\\{",
            beginCaptures: {
                "0" => {
                    name: "punctuation.section.block.begin.bracket.curly.c"
                }
            },
            end: "\\}",
            endCaptures: {
                "0" => {
                    name: "punctuation.section.block.end.bracket.curly.c"
                }
            },
            name: "meta.block.cpp",
            patterns: [
                {
                    captures: {
                        "1" => {
                            name: "support.function.any-method.c"
                        },
                        "2" => {
                            name: "punctuation.definition.parameters.c"
                        }
                    },
                    match: "(?x)\n(\n  (?!while|for|do|if|else|switch|catch|return)\n  (?:\\b[A-Za-z_][A-Za-z0-9_]*+\\b|::)*+ # actual name\n)\n\\s*(\\() # opening bracket",
                    name: "meta.function-call.c"
                },
                {
                    include: "$base"
                }
            ]
        },
        "constructor" => {
            patterns: [
                {
                    begin: "(?x)\n(?:^\\s*)  # beginning of line\n((?!while|for|do|if|else|switch|catch)[A-Za-z_][A-Za-z0-9_:]*) # actual name\n\\s*(\\()  # opening bracket",
                    beginCaptures: {
                        "1" => {
                            name: "entity.name.function.constructor.cpp"
                        },
                        "2" => {
                            name: "punctuation.definition.parameters.begin.c"
                        }
                    },
                    end: "\\)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.parameters.end.c"
                        }
                    },
                    name: "meta.function.constructor.cpp",
                    patterns: [
                        {
                            include: "#probably_a_parameter"
                        },
                        {
                            include: "#function-innards-c"
                        }
                    ]
                },
                {
                    begin: "(?x)\n(:)\n(\n  (?=\n    \\s*[A-Za-z_][A-Za-z0-9_:]* # actual name\n    \\s* (\\() # opening bracket\n  )\n)",
                    beginCaptures: {
                        "1" => {
                            name: "punctuation.definition.initializer-list.parameters.c"
                        }
                    },
                    end: "(?=\\{)",
                    name: "meta.function.constructor.initializer-list.cpp",
                    patterns: [
                        {
                            include: "$base"
                        }
                    ]
                }
            ]
        },
        "special_block" => {
            patterns: [
                {
                    begin: "\\b(using)\\b\\s*(namespace)\\b\\s*((?:[_A-Za-z][_A-Za-z0-9]*\\b(::)?)*)",
                    beginCaptures: {
                        "1" => {
                            name: "keyword.control.cpp"
                        },
                        "2" => {
                            name: "storage.type.namespace.cpp"
                        },
                        "3" => {
                            name: "entity.name.type.namespace.cpp"
                        }
                    },
                    end: ";",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.terminator.statement.c"
                        }
                    },
                    name: "meta.using-namespace-declaration.cpp"
                },
                {
                    begin: -namespace_pattern_2_groups,
                    beginCaptures: {
                        "1" => {
                            name: "storage.type.namespace.cpp"
                        },
                        "2" => {
                            patterns: [
                                {
                                    match: variable_name,
                                    name: "entity.name.type.cpp",
                                },
                                {
                                    match: -/::/,
                                    name: "punctuation.separator.namespace.access.cpp"
                                }
                            ]
                        }
                    },
                    captures: {
                        "1" => {
                            name: "keyword.control.namespace.$2"
                        }
                    },
                    end: "(?<=\\})|(?=(;|,|\\(|\\)|>|\\[|\\]|=))",
                    name: "meta.namespace-block.cpp",
                    patterns: [
                        {
                            begin: "\\{",
                            beginCaptures: {
                                "0" => {
                                    name: "punctuation.definition.scope.cpp"
                                }
                            },
                            end: "\\}",
                            endCaptures: {
                                "0" => {
                                    name: "punctuation.definition.scope.cpp"
                                }
                            },
                            patterns: [
                                {
                                    include: "#special_block"
                                },
                                {
                                    include: "#constructor"
                                },
                                {
                                    include: "$base"
                                }
                            ]
                        },
                        {
                            include: "$base"
                        }
                    ]
                },
                {
                    begin: "\\b(?:(class)|(struct))\\b\\s*([_A-Za-z][_A-Za-z0-9]*\\b)?+(\\s*:\\s*(public|protected|private)\\s*([_A-Za-z][_A-Za-z0-9]*\\b)((\\s*,\\s*(public|protected|private)\\s*[_A-Za-z][_A-Za-z0-9]*\\b)*))?",
                    beginCaptures: {
                        "1" => {
                            name: "storage.type.class.cpp"
                        },
                        "2" => {
                            name: "storage.type.struct.cpp"
                        },
                        "3" => {
                            name: "entity.name.type.cpp"
                        },
                        "5" => {
                            name: "storage.type.modifier.access.cpp"
                        },
                        "6" => {
                            name: "entity.name.type.inherited.cpp"
                        },
                        "7" => {
                            patterns: [
                                {
                                    match: "(public|protected|private)",
                                    name: "storage.type.modifier.access.cpp"
                                },
                                {
                                    match: "[_A-Za-z][_A-Za-z0-9]*",
                                    name: "entity.name.type.inherited.cpp"
                                }
                            ]
                        }
                    },
                    end: "(?<=\\})|(?=(;|\\(|\\)|>|\\[|\\]|=))",
                    name: "meta.class-struct-block.cpp",
                    patterns: [
                        {
                            include: "#angle_brackets"
                        },
                        {
                            begin: "\\{",
                            beginCaptures: {
                                "0" => {
                                    name: "punctuation.section.block.begin.bracket.curly.cpp"
                                }
                            },
                            end: "(\\})(\\s*\\n)?",
                            endCaptures: {
                                "1" => {
                                    name: "punctuation.section.block.end.bracket.curly.cpp"
                                },
                                "2" => {
                                    name: "invalid.illegal.you-forgot-semicolon.cpp"
                                }
                            },
                            patterns: [
                                {
                                    include: "#special_block"
                                },
                                {
                                    include: "#constructor"
                                },
                                {
                                    include: "$base"
                                }
                            ]
                        },
                        {
                            include: "$base"
                        }
                    ]
                },
                {
                    begin: "\\b(extern)(?=\\s*\")",
                    beginCaptures: {
                        "1" => {
                            name: "storage.modifier.cpp"
                        }
                    },
                    end: "(?<=\\})|(?=\\w)|(?=\\s*#\\s*endif\\b)",
                    name: "meta.extern-block.cpp",
                    patterns: [
                        {
                            begin: "\\{",
                            beginCaptures: {
                                "0" => {
                                    name: "punctuation.section.block.begin.bracket.curly.c"
                                }
                            },
                            end: "\\}|(?=\\s*#\\s*endif\\b)",
                            endCaptures: {
                                "0" => {
                                    name: "punctuation.section.block.end.bracket.curly.c"
                                }
                            },
                            patterns: [
                                {
                                    include: "#special_block"
                                },
                                {
                                    include: "$base"
                                }
                            ]
                        },
                        {
                            include: "$base"
                        }
                    ]
                }
            ]
        },
        "strings" => {
            patterns: [
                {
                    begin: "(u|u8|U|L)?\"",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.cpp"
                        },
                        "1" => {
                            name: "meta.encoding.cpp"
                        }
                    },
                    end: "\"",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.cpp"
                        }
                    },
                    name: "string.quoted.double.cpp",
                    patterns: [
                        {
                            match: "\\\\u\\h{4}|\\\\U\\h{8}",
                            name: "constant.character.escape.cpp"
                        },
                        {
                            match: "\\\\['\"?\\\\abfnrtv]",
                            name: "constant.character.escape.cpp"
                        },
                        {
                            match: "\\\\[0-7]{1,3}",
                            name: "constant.character.escape.cpp"
                        },
                        {
                            match: "\\\\x\\h+",
                            name: "constant.character.escape.cpp"
                        },
                        {
                            include: "#string_placeholder-c"
                        }
                    ]
                },
                {
                    begin: "(u|u8|U|L)?R\"(?:([^ ()\\\\\\t]{0,16})|([^ ()\\\\\\t]*))\\(",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.cpp"
                        },
                        "1" => {
                            name: "meta.encoding.cpp"
                        },
                        "3" => {
                            name: "invalid.illegal.delimiter-too-long.cpp"
                        }
                    },
                    end: "\\)\\2(\\3)\"",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.cpp"
                        },
                        "1" => {
                            name: "invalid.illegal.delimiter-too-long.cpp"
                        }
                    },
                    name: "string.quoted.double.raw.cpp"
                }
            ]
        },
        "probably_a_parameter" => {
            match: -probably_a_parameter_2_groups,
            captures: {
                "1" => {
                    name: "variable.parameter.probably.defaulted.c"
                },
                "2" => {
                    name: "variable.parameter.probably.c"
                }
            }
        },
        "operator_overload" => {
            begin: -operator_overload_4_groups,
            beginCaptures: {
                "1" => {
                    name: "entity.scope.c"
                },
                "2" => {
                    name: "entity.name.operator.overload.c"
                },
                "3" => {
                    name: "entity.name.operator.overloadee.c"
                },
                "4" => {
                    name: "punctuation.section.parameters.begin.bracket.round.c"
                }
            },
            end: -/\)/,
            endCaptures: {
                "0" => {
                    name: "punctuation.section.parameters.end.bracket.round.c"
                }
            },
            name: "meta.function.definition.parameters.operator-overload.c",
            patterns: [
                {
                    include: "#probably_a_parameter"
                },
                {
                    include: "#function-innards-c"
                }
            ]
        },
        "access-method" => {
            name: "meta.function-call.member.c",
            begin: "([a-zA-Z_][a-zA-Z_0-9]*|(?<=[\\]\\)]))\\s*(?:(\\.)|(->))((?:(?:[a-zA-Z_][a-zA-Z_0-9]*)\\s*(?:(?:\\.)|(?:->)))*)\\s*([a-zA-Z_][a-zA-Z_0-9]*)(\\()",
            beginCaptures: {
                "1" => {
                    name: "variable.object.c"
                },
                "2" => {
                    name: "punctuation.separator.dot-access.c"
                },
                "3" => {
                    name: "punctuation.separator.pointer-access.c"
                },
                "4" => {
                    patterns: [
                        {
                            match: "\\.",
                            name: "punctuation.separator.dot-access.c"
                        },
                        {
                            match: "->",
                            name: "punctuation.separator.pointer-access.c"
                        },
                        {
                            match: "[a-zA-Z_][a-zA-Z_0-9]*",
                            name: "variable.object.c"
                        },
                        {
                            name: "everything.else",
                            match: ".+"
                        }
                    ]
                },
                "5" => {
                    name: "entity.name.function.member.c"
                },
                "6" => {
                    name: "punctuation.section.arguments.begin.bracket.round.function.member.c"
                }
            },
            end: "\\)",
            endCaptures: {
                "0" => {
                    name: "punctuation.section.arguments.end.bracket.round.function.member.c"
                }
            },
            patterns: [
                {
                    include: "#function-call-innards-c"
                }
            ]
        },
        "access-member" => {
            name: "variable.object.access.c",
            match: -member_pattern_5_groups,
            captures: {
                "1" => {
                    name: "variable.object.c"
                },
                "2" => {
                    name: "punctuation.separator.dot-access.c"
                },
                "3" => {
                    name: "punctuation.separator.pointer-access.c"
                },
                "4" => {
                    patterns: [
                        {
                            match: -/\./,
                            name: "punctuation.separator.dot-access.c"
                        },
                        {
                            match: -/->/,
                            name: "punctuation.separator.pointer-access.c"
                        },
                        {
                            match: -variable_name_without_bounds,
                            name: "variable.object.c"
                        },
                        {
                            match: -/.+/,
                            name: "everything.else",
                        }
                    ]
                },
                "5" => {
                    name: "variable.other.member.c"
                }
            }
        },
        "block-c" => {
            patterns: [
                {
                    begin: "{",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.block.begin.bracket.curly.c"
                        }
                    },
                    end: "}|(?=\\s*#\\s*(?:elif|else|endif)\\b)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.block.end.bracket.curly.c"
                        }
                    },
                    name: "meta.block.c",
                    patterns: [
                        {
                            include: "#block_innards-c"
                        }
                    ]
                }
            ]
        },
        "block_innards-c" => {
            patterns: [
                {
                    include: "#preprocessor-rule-enabled-block"
                },
                {
                    include: "#preprocessor-rule-disabled-block"
                },
                {
                    include: "#preprocessor-rule-conditional-block"
                },
                {
                    include: "#access-method"
                },
                {
                    include: "#access-member"
                },
                {
                    include: "#c_function_call"
                },
                {
                    name: "meta.initialization.c",
                    begin: "(?x)\n(?:\n  (?:\n\t(?=\\s)(?<!else|new|return)\n\t(?<=\\w) \\s+(and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)  # or word + space before name\n  )\n)\n(\n  (?:[A-Za-z_][A-Za-z0-9_]*+ | :: )++   # actual name\n  |\n  (?:(?<=operator) (?:[-*&<>=+!]+ | \\(\\) | \\[\\]))\n)\n\\s*(\\() # opening bracket",
                    beginCaptures: {
                        "1" => {
                            name: "variable.other.c"
                        },
                        "2" => {
                            name: "punctuation.section.parens.begin.bracket.round.initialization.c"
                        }
                    },
                    end: "\\)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.end.bracket.round.initialization.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#function-call-innards-c"
                        }
                    ]
                },
                {
                    begin: "{",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.block.begin.bracket.curly.c"
                        }
                    },
                    end: "}|(?=\\s*#\\s*(?:elif|else|endif)\\b)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.block.end.bracket.curly.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#block_innards-c"
                        }
                    ]
                },
                {
                    include: "#parens-block-c"
                },
                {
                    include: "$base"
                }
            ]
        },
        "c_function_call" => {
            begin: "(?x)\n(?!(?:while|for|do|if|else|switch|catch|return|typeid|alignof|alignas|sizeof|and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)\\s*\\()\n(?=\n(?:[A-Za-z_][A-Za-z0-9_]*+|::)++\\s*#{-maybe(template_call_match)}\\(  # actual name\n|\n(?:(?<=operator)(?:[-*&<>=+!]+|\\(\\)|\\[\\]))\\s*\\(\n)",
            end: "(?<=\\))(?!\\w)",
            name: "meta.function-call.c",
            patterns: [
                {
                    include: "#function-call-innards-c"
                }
            ]
        },
        "comments-c" => {
            patterns: [
                {
                    captures: {
                        "1" => {
                            name: "meta.toc-list.banner.block.c"
                        }
                    },
                    match: "^/\\* =(\\s*.*?)\\s*= \\*/$\\n?",
                    name: "comment.block.c"
                },
                {
                    begin: "/\\*",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.comment.begin.c"
                        }
                    },
                    end: "\\*/",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.comment.end.c"
                        }
                    },
                    name: "comment.block.c"
                },
                {
                    match: "\\*/.*\\n",
                    name: "invalid.illegal.stray-comment-end.c"
                },
                {
                    captures: {
                        "1" => {
                            name: "meta.toc-list.banner.line.c"
                        }
                    },
                    match: "^// =(\\s*.*?)\\s*=\\s*$\\n?",
                    name: "comment.line.banner.cpp"
                },
                {
                    begin: "(^[ \\t]+)?(?=//)",
                    beginCaptures: {
                        "1" => {
                            name: "punctuation.whitespace.comment.leading.cpp"
                        }
                    },
                    end: "(?!\\G)",
                    patterns: [
                        {
                            begin: "//",
                            beginCaptures: {
                                "0" => {
                                    name: "punctuation.definition.comment.cpp"
                                }
                            },
                            end: "(?=\\n)",
                            name: "comment.line.double-slash.cpp",
                            patterns: [
                                {
                                    include: "#line_continuation_character"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "disabled" => {
            begin: "^\\s*#\\s*if(n?def)?\\b.*$",
            end: "^\\s*#\\s*endif\\b",
            patterns: [
                {
                    include: "#disabled"
                },
                {
                    include: "#pragma-mark"
                }
            ]
        },
        "line_continuation_character" => {
            patterns: [
                {
                    match: "(\\\\)\\n",
                    captures: {
                        "1" => {
                            name: "constant.character.escape.line-continuation.c"
                        }
                    }
                }
            ]
        },
        "numbers-c" => {
            patterns: [
                {
                    match: "\\b((0(x|X)[0-9a-fA-F]([0-9a-fA-F']*[0-9a-fA-F])?)|(0(b|B)[01]([01']*[01])?)|(([0-9]([0-9']*[0-9])?\\.?[0-9]*([0-9']*[0-9])?)|(\\.[0-9]([0-9']*[0-9])?))((e|E)(\\+|-)?[0-9]([0-9']*[0-9])?)?)(L|l|UL|ul|u|U|F|f|ll|LL|ull|ULL)?\\b",
                    name: "constant.numeric.c",
                    captures: {
                        "0" => {
                            patterns: [
                                {
                                    match: /[^\d\.]+/,
                                    name: "keyword.other.unit.cpp",
                                },
                            ]
                        },
                    },
                }
            ]
        },
        "parens-c" => {
            name: "punctuation.section.parens-c\b",
            begin: "\\(",
            beginCaptures: {
                "0" => {
                    name: "punctuation.section.parens.begin.bracket.round.c"
                }
            },
            end: "\\)",
            endCaptures: {
                "0" => {
                    name: "punctuation.section.parens.end.bracket.round.c"
                }
            },
            patterns: [
                {
                    include: "$base"
                }
            ]
        },
        "parens-block-c" => {
            name: "meta.block.parens.cpp",
            begin: "\\(",
            beginCaptures: {
                "0" => {
                    name: "punctuation.section.parens.begin.bracket.round.c"
                }
            },
            end: "\\)",
            endCaptures: {
                "0" => {
                    name: "punctuation.section.parens.end.bracket.round.c"
                }
            },
            patterns: [
                {
                    include: "#block_innards-c"
                },
                {
                    match: -lookBehindToAvoid(/:/).then(/:/).lookAheadToAvoid(/:/),
                    name: "punctuation.range-based.cpp"
                }
            ]
        },
        "pragma-mark" => {
            captures: {
                "1" => {
                    name: "meta.preprocessor.pragma.c"
                },
                "2" => {
                    name: "keyword.control.directive.pragma.pragma-mark.c"
                },
                "3" => {
                    name: "punctuation.definition.directive.c"
                },
                "4" => {
                    name: "entity.name.tag.pragma-mark.c"
                }
            },
            match: "^\\s*(((#)\\s*pragma\\s+mark)\\s+(.*))",
            name: "meta.section"
        },
        "operators-c" => {
            patterns: [
                {
                    match: "(?<![\\w$])(sizeof)(?![\\w$])",
                    name: "keyword.operator.sizeof.c"
                },
                {
                    match: "--",
                    name: "keyword.operator.decrement.c"
                },
                {
                    match: "\\+\\+",
                    name: "keyword.operator.increment.c"
                },
                {
                    match: "%=|\\+=|-=|\\*=|(?<!\\()/=",
                    name: "keyword.operator.assignment.compound.c"
                },
                {
                    match: "&=|\\^=|<<=|>>=|\\|=",
                    name: "keyword.operator.assignment.compound.bitwise.c"
                },
                {
                    match: "<<|>>",
                    name: "keyword.operator.bitwise.shift.c"
                },
                {
                    match: "!=|<=|>=|==|<|>",
                    name: "keyword.operator.comparison.c"
                },
                {
                    match: "&&|!|\\|\\|",
                    name: "keyword.operator.logical.c"
                },
                {
                    match: "&|\\||\\^|~",
                    name: "keyword.operator.c"
                },
                {
                    match: "=",
                    name: "keyword.operator.assignment.c"
                },
                {
                    match: "%|\\*|/|-|\\+",
                    name: "keyword.operator.c"
                },
                {
                    begin: "\\?",
                    beginCaptures: {
                        "0" => {
                            name: "keyword.operator.ternary.c"
                        }
                    },
                    end: ":",
                    applyEndPatternLast: true,
                    endCaptures: {
                        "0" => {
                            name: "keyword.operator.ternary.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#access-method"
                        },
                        {
                            include: "#access-member"
                        },
                        {
                            include: "#c_function_call"
                        },
                        {
                            include: "$base"
                        }
                    ]
                }
            ]
        },
        "strings-c" => {
            patterns: [
                {
                    begin: "\"",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "\"",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.double.c",
                    patterns: [
                        {
                            include: "#string_escaped_char-c"
                        },
                        {
                            include: "#string_placeholder-c"
                        },
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                },
                {
                    begin: "'",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "'",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.single.c",
                    patterns: [
                        {
                            include: "#string_escaped_char-c"
                        },
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                }
            ]
        },
        "string_escaped_char-c" => {
            patterns: [
                {
                    match: "(?x)\\\\ (\n\\\\\t\t\t |\n[abefnprtv'\"?]   |\n[0-3]\\d{,2}\t |\n[4-7]\\d?\t\t|\nx[a-fA-F0-9]{,2} |\nu[a-fA-F0-9]{,4} |\nU[a-fA-F0-9]{,8} )",
                    name: "constant.character.escape.c"
                },
                {
                    match: "\\\\.",
                    name: "invalid.illegal.1.unknown-escape.c"
                }
            ]
        },
        "string_placeholder-c" => {
            patterns: [
                {
                    match: "(?x) %\n(\\d+\\$)?\t\t\t\t\t\t   # field (argument #)\n[#0\\- +']*\t\t\t\t\t\t  # flags\n[,;:_]?\t\t\t\t\t\t\t  # separator character (AltiVec)\n((-?\\d+)|\\*(-?\\d+\\$)?)?\t\t  # minimum field width\n(\\.((-?\\d+)|\\*(-?\\d+\\$)?)?)?\t# precision\n(hh|h|ll|l|j|t|z|q|L|vh|vl|v|hv|hl)? # length modifier\n[diouxXDOUeEfFgGaACcSspn%]\t\t   # conversion type",
                    name: "constant.other.placeholder.c"
                },
                # I don't think these are actual escapes, and they incorrectly mark valid strings
                # It might be related to printf and format from C (which is low priority for C++)
                # {
                #     match: "(%)(?!\"\\s*(PRI|SCN))",
                #     captures: {
                #         "1" => {
                #             name: "constant.other.placeholder.c"
                #         }
                #     }
                # }
            ]
        },
        "storage_types-c" => {
            patterns: [
                {
                    match: -non_primitive_types.or(/_Bool|_Complex|_Imaginary/),
                    name: "storage.type.built-in.c",
                },
                {
                    match: -primitive_types,
                    name: "storage.type.built-in.primitive.c",
                },
                {
                    match: -/\b(asm|__asm__|enum|struct|union)\b/,
                    name: "storage.type.$1.c"
                },
            ]
        },
        "vararg_ellipses-c" => {
            match: "(?<!\\.)\\.\\.\\.(?!\\.)",
            name: "punctuation.vararg-ellipses.c"
        },
        "preprocessor-rule-conditional" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if(?:n?def)?\\b)",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#preprocessor-rule-enabled-elif"
                        },
                        {
                            include: "#preprocessor-rule-enabled-else"
                        },
                        {
                            include: "#preprocessor-rule-disabled-elif"
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "$base"
                        }
                    ]
                },
                {
                    match: "^\\s*#\\s*(else|elif|endif)\\b",
                    captures: {
                        "0" => {
                            name: "invalid.illegal.stray-$1.c"
                        }
                    }
                }
            ]
        },
        "preprocessor-rule-conditional-block" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if(?:n?def)?\\b)",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#preprocessor-rule-enabled-elif-block"
                        },
                        {
                            include: "#preprocessor-rule-enabled-else-block"
                        },
                        {
                            include: "#preprocessor-rule-disabled-elif"
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#block_innards-c"
                        }
                    ]
                },
                {
                    match: "^\\s*#\\s*(else|elif|endif)\\b",
                    captures: {
                        "0" => {
                            name: "invalid.illegal.stray-$1.c"
                        }
                    }
                }
            ]
        },
        "preprocessor-rule-conditional-line" => {
            patterns: [
                {
                    match: "(?:\\bdefined\\b\\s*$)|(?:\\bdefined\\b(?=\\s*\\(*\\s*(?:(?!defined\\b)[a-zA-Z_$][\\w$]*\\b)\\s*\\)*\\s*(?:\\n|//|/\\*|\\?|\\:|&&|\\|\\||\\\\\\s*\\n)))",
                    name: "keyword.control.directive.conditional.c"
                },
                {
                    match: "\\bdefined\\b",
                    name: "invalid.illegal.macro-name.c"
                },
                {
                    include: "#comments-c"
                },
                {
                    include: "#strings-c"
                },
                {
                    include: "#numbers-c"
                },
                {
                    begin: "\\?",
                    beginCaptures: {
                        "0" => {
                            name: "keyword.operator.ternary.c"
                        }
                    },
                    end: ":",
                    endCaptures: {
                        "0" => {
                            name: "keyword.operator.ternary.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#preprocessor-rule-conditional-line"
                        }
                    ]
                },
                {
                    include: "#operators-c"
                },
                {
                    include: "#constants"
                },
                {
                    match: -preprocessor_name_no_bounds,
                    name: "entity.name.function.preprocessor.c"
                },
                {
                    include: "#line_continuation_character"
                },
                {
                    begin: "\\(",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.begin.bracket.round.c"
                        }
                    },
                    end: "\\)|(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#preprocessor-rule-conditional-line"
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-disabled" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if\\b)(?=\\s*\\(*\\b0+\\b\\)*\\s*(?:$|//|/\\*))",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#comments-c"
                        },
                        {
                            include: "#preprocessor-rule-enabled-elif"
                        },
                        {
                            include: "#preprocessor-rule-enabled-else"
                        },
                        {
                            include: "#preprocessor-rule-disabled-elif"
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:elif|else|endif)\\b))",
                            patterns: [
                                {
                                    begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                                    end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                                    name: "meta.preprocessor.c",
                                    patterns: [
                                        {
                                            include: "#preprocessor-rule-conditional-line"
                                        }
                                    ]
                                },
                                {
                                    include: "$base"
                                }
                            ]
                        },
                        {
                            begin: "\\n",
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.if-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-disabled-block" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if\\b)(?=\\s*\\(*\\b0+\\b\\)*\\s*(?:$|//|/\\*))",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#comments-c"
                        },
                        {
                            include: "#preprocessor-rule-enabled-elif-block"
                        },
                        {
                            include: "#preprocessor-rule-enabled-else-block"
                        },
                        {
                            include: "#preprocessor-rule-disabled-elif"
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:elif|else|endif)\\b))",
                            patterns: [
                                {
                                    begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                                    end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                                    name: "meta.preprocessor.c",
                                    patterns: [
                                        {
                                            include: "#preprocessor-rule-conditional-line"
                                        }
                                    ]
                                },
                                {
                                    include: "#block_innards-c"
                                }
                            ]
                        },
                        {
                            begin: "\\n",
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.if-branch.in-block.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-disabled-elif" => {
            begin: "^\\s*((#)\\s*elif\\b)(?=\\s*\\(*\\b0+\\b\\)*\\s*(?:$|//|/\\*))",
            beginCaptures: {
                "0" => {
                    name: "meta.preprocessor.c"
                },
                "1" => {
                    name: "keyword.control.directive.conditional.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=^\\s*((#)\\s*(?:elif|else|endif)\\b))",
            patterns: [
                {
                    begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                    end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                    name: "meta.preprocessor.c",
                    patterns: [
                        {
                            include: "#preprocessor-rule-conditional-line"
                        }
                    ]
                },
                {
                    include: "#comments-c"
                },
                {
                    begin: "\\n",
                    end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                    "contentName" => "comment.block.preprocessor.elif-branch.c",
                    patterns: [
                        {
                            include: "#disabled"
                        },
                        {
                            include: "#pragma-mark"
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-enabled" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if\\b)(?=\\s*\\(*\\b0*1\\b\\)*\\s*(?:$|//|/\\*))",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        },
                        "3" => {
                            name: "constant.numeric.preprocessor.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#comments-c"
                        },
                        {
                            begin: "^\\s*((#)\\s*else\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*endif\\b))",
                            "contentName" => "comment.block.preprocessor.else-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.if-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "\\n",
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            patterns: [
                                {
                                    include: "$base"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-enabled-block" => {
            patterns: [
                {
                    begin: "^\\s*((#)\\s*if\\b)(?=\\s*\\(*\\b0*1\\b\\)*\\s*(?:$|//|/\\*))",
                    beginCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    end: "^\\s*((#)\\s*endif\\b)",
                    endCaptures: {
                        "0" => {
                            name: "meta.preprocessor.c"
                        },
                        "1" => {
                            name: "keyword.control.directive.conditional.c"
                        },
                        "2" => {
                            name: "punctuation.definition.directive.c"
                        }
                    },
                    patterns: [
                        {
                            begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                            end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?=\\n)",
                            name: "meta.preprocessor.c",
                            patterns: [
                                {
                                    include: "#preprocessor-rule-conditional-line"
                                }
                            ]
                        },
                        {
                            include: "#comments-c"
                        },
                        {
                            begin: "^\\s*((#)\\s*else\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*endif\\b))",
                            "contentName" => "comment.block.preprocessor.else-branch.in-block.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "^\\s*((#)\\s*elif\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.if-branch.in-block.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "\\n",
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            patterns: [
                                {
                                    include: "#block_innards-c"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-enabled-elif" => {
            begin: "^\\s*((#)\\s*elif\\b)(?=\\s*\\(*\\b0*1\\b\\)*\\s*(?:$|//|/\\*))",
            beginCaptures: {
                "0" => {
                    name: "meta.preprocessor.c"
                },
                "1" => {
                    name: "keyword.control.directive.conditional.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=^\\s*((#)\\s*endif\\b))",
            patterns: [
                {
                    begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                    end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                    name: "meta.preprocessor.c",
                    patterns: [
                        {
                            include: "#preprocessor-rule-conditional-line"
                        }
                    ]
                },
                {
                    include: "#comments-c"
                },
                {
                    begin: "\\n",
                    end: "(?=^\\s*((#)\\s*(?:endif)\\b))",
                    patterns: [
                        {
                            begin: "^\\s*((#)\\s*(else)\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*endif\\b))",
                            "contentName" => "comment.block.preprocessor.elif-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "^\\s*((#)\\s*(elif)\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.elif-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            include: "$base"
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-enabled-elif-block" => {
            begin: "^\\s*((#)\\s*elif\\b)(?=\\s*\\(*\\b0*1\\b\\)*\\s*(?:$|//|/\\*))",
            beginCaptures: {
                "0" => {
                    name: "meta.preprocessor.c"
                },
                "1" => {
                    name: "keyword.control.directive.conditional.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=^\\s*((#)\\s*endif\\b))",
            patterns: [
                {
                    begin: "\\G(?=.)(?!//|/\\*(?!.*\\\\\\s*\\n))",
                    end: "(?=//)|(?=/\\*(?!.*\\\\\\s*\\n))|(?<!\\\\)(?=\\n)",
                    name: "meta.preprocessor.c",
                    patterns: [
                        {
                            include: "#preprocessor-rule-conditional-line"
                        }
                    ]
                },
                {
                    include: "#comments-c"
                },
                {
                    begin: "\\n",
                    end: "(?=^\\s*((#)\\s*(?:endif)\\b))",
                    patterns: [
                        {
                            begin: "^\\s*((#)\\s*(else)\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*endif\\b))",
                            "contentName" => "comment.block.preprocessor.elif-branch.in-block.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            begin: "^\\s*((#)\\s*(elif)\\b)",
                            beginCaptures: {
                                "0" => {
                                    name: "meta.preprocessor.c"
                                },
                                "1" => {
                                    name: "keyword.control.directive.conditional.c"
                                },
                                "2" => {
                                    name: "punctuation.definition.directive.c"
                                }
                            },
                            end: "(?=^\\s*((#)\\s*(?:else|elif|endif)\\b))",
                            "contentName" => "comment.block.preprocessor.elif-branch.c",
                            patterns: [
                                {
                                    include: "#disabled"
                                },
                                {
                                    include: "#pragma-mark"
                                }
                            ]
                        },
                        {
                            include: "#block_innards-c"
                        }
                    ]
                }
            ]
        },
        "preprocessor-rule-enabled-else" => {
            begin: "^\\s*((#)\\s*else\\b)",
            beginCaptures: {
                "0" => {
                    name: "meta.preprocessor.c"
                },
                "1" => {
                    name: "keyword.control.directive.conditional.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=^\\s*((#)\\s*endif\\b))",
            patterns: [
                {
                    include: "$base"
                }
            ]
        },
        "preprocessor-rule-enabled-else-block" => {
            begin: "^\\s*((#)\\s*else\\b)",
            beginCaptures: {
                "0" => {
                    name: "meta.preprocessor.c"
                },
                "1" => {
                    name: "keyword.control.directive.conditional.c"
                },
                "2" => {
                    name: "punctuation.definition.directive.c"
                }
            },
            end: "(?=^\\s*((#)\\s*endif\\b))",
            patterns: [
                {
                    include: "#block_innards-c"
                }
            ]
        },
        "preprocessor-rule-define-line-contents" => {
            patterns: [
                {
                    include: "#vararg_ellipses-c"
                },
                {
                    begin: "{",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.block.begin.bracket.curly.c"
                        }
                    },
                    end: "}|(?=\\s*#\\s*(?:elif|else|endif)\\b)|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.block.end.bracket.curly.c"
                        }
                    },
                    name: "meta.block.c",
                    patterns: [
                        {
                            include: "#preprocessor-rule-define-line-blocks"
                        }
                    ]
                },
                {
                    match: "\\(",
                    name: "punctuation.section.parens.begin.bracket.round.c"
                },
                {
                    match: "\\)",
                    name: "punctuation.section.parens.end.bracket.round.c"
                },
                {
                    begin: "(?x)\n(?!(?:while|for|do|if|else|switch|catch|return|typeid|alignof|alignas|sizeof|and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas|asm|__asm__|auto|bool|_Bool|char|_Complex|double|enum|float|_Imaginary|int|long|short|signed|struct|typedef|union|unsigned|void)\\s*\\()\n(?=\n  (?:[A-Za-z_][A-Za-z0-9_]*+|::)++\\s*\\(  # actual name\n  |\n  (?:(?<=operator)(?:[-*&<>=+!]+|\\(\\)|\\[\\]))\\s*\\(\n)",
                    end: "(?<=\\))(?!\\w)|(?<!\\\\)(?=\\s*\\n)",
                    name: "meta.function.c",
                    patterns: [
                        {
                            include: "#preprocessor-rule-define-line-functions"
                        }
                    ]
                },
                {
                    begin: "\"",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "\"|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.double.c",
                    patterns: [
                        {
                            include: "#string_escaped_char-c"
                        },
                        {
                            include: "#string_placeholder-c"
                        },
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                },
                {
                    begin: "'",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.begin.c"
                        }
                    },
                    end: "'|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.definition.string.end.c"
                        }
                    },
                    name: "string.quoted.single.c",
                    patterns: [
                        {
                            include: "#string_escaped_char-c"
                        },
                        {
                            include: "#line_continuation_character"
                        }
                    ]
                },
                {
                    include: "#access-method"
                },
                {
                    include: "#access-member"
                },
                {
                    include: "$base"
                }
            ]
        },
        "preprocessor-rule-define-line-blocks" => {
            patterns: [
                {
                    begin: "{",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.block.begin.bracket.curly.c"
                        }
                    },
                    end: "}|(?=\\s*#\\s*(?:elif|else|endif)\\b)|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.block.end.bracket.curly.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#preprocessor-rule-define-line-blocks"
                        },
                        {
                            include: "#preprocessor-rule-define-line-contents"
                        }
                    ]
                },
                {
                    include: "#preprocessor-rule-define-line-contents"
                }
            ]
        },
        "preprocessor-rule-define-line-functions" => {
            patterns: [
                {
                    include: "#comments-c"
                },
                {
                    include: "#storage_types-c"
                },
                {
                    include: "#vararg_ellipses-c"
                },
                {
                    include: "#access-method"
                },
                {
                    include: "#access-member"
                },
                {
                    include: "#operators-c"
                },
                {
                    begin: "(?x)\n(?!(?:while|for|do|if|else|switch|catch|return|typeid|alignof|alignas|sizeof|and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)\\s*\\()\n(\n(?:[A-Za-z_][A-Za-z0-9_]*+|::)++  # actual name\n|\n(?:(?<=operator)(?:[-*&<>=+!]+|\\(\\)|\\[\\]))\n)\n\\s*(\\()",
                    beginCaptures: {
                        "1" => {
                            name: "entity.name.function.c"
                        },
                        "2" => {
                            name: "punctuation.section.arguments.begin.bracket.round.c"
                        }
                    },
                    end: "(\\))|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "1" => {
                            name: "punctuation.section.arguments.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#preprocessor-rule-define-line-functions"
                        }
                    ]
                },
                {
                    begin: "\\(",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.begin.bracket.round.c"
                        }
                    },
                    end: "(\\))|(?<!\\\\)(?=\\s*\\n)",
                    endCaptures: {
                        "1" => {
                            name: "punctuation.section.parens.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#preprocessor-rule-define-line-functions"
                        }
                    ]
                },
                {
                    include: "#preprocessor-rule-define-line-contents"
                }
            ]
        },
        "function-innards-c" => {
            patterns: [
                {
                    include: "#comments-c"
                },
                {
                    include: "#storage_types-c"
                },
                {
                    include: "#operators-c"
                },
                {
                    include: "#vararg_ellipses-c"
                },
                {
                    name: "meta.function.definition.parameters",
                    begin: "(?x)\n(?!(?:while|for|do|if|else|switch|catch|return|typeid|alignof|alignas|sizeof|and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)\\s*\\()\n(\n(?:[A-Za-z_][A-Za-z0-9_]*+|::)++ # actual name\n|\n(?:(?<=operator)(?:[-*&<>=+!]+|\\(\\)|\\[\\]))\n)\n\\s*(\\()",
                    beginCaptures: {
                        "1" => {
                            name: "entity.name.function.c"
                        },
                        "2" => {
                            name: "punctuation.section.parameters.begin.bracket.round.c"
                        },
                    },
                    end: -/\)|:/,
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.parameters.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#probably_a_parameter"
                        },
                        {
                            include: "#function-innards-c"
                        }
                    ]
                },
                {
                    begin: "\\(",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.begin.bracket.round.c"
                        }
                    },
                    end: "\\)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#function-innards-c"
                        }
                    ]
                },
                {
                    include: "$base"
                }
            ]
        },
        "function-call-innards-c" => {
            patterns: [
                {
                    include: "#comments-c"
                },
                {
                    include: "#storage_types-c"
                },
                {
                    include: "#access-method"
                },
                {
                    include: "#access-member"
                },
                {
                    include: "#operators-c"
                },
                {
                    begin: "(?x)\n(?!(?:while|for|do|if|else|switch|catch|return|typeid|alignof|alignas|sizeof|and|and_eq|bitand|bitor|compl|not|not_eq|or|or_eq|typeid|xor|xor_eq|alignof|alignas)\\s*\\()\n(\n(?:[A-Za-z_][A-Za-z0-9_]*+|::)++\\s*(#{-maybe(template_call_match)}) # actual name\n|\n(?:(?<=operator)(?:[-*&<>=+!]+|\\(\\)|\\[\\]))\n)\n\\s*(\\()",
                    beginCaptures: {
                        "1" => {
                            name: "entity.name.function.call.c"
                        },
                        "2" => {
                            patterns: [
                                {
                                    include: "#template-call-innards"
                                }
                            ]
                        },
                        "3" => {
                            name: "punctuation.section.arguments.begin.bracket.round.c"
                        },
                    },
                    end: "\\)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.arguments.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#function-call-innards-c"
                        }
                    ]
                },
                {
                    begin: "\\(",
                    beginCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.begin.bracket.round.c"
                        }
                    },
                    end: "\\)",
                    endCaptures: {
                        "0" => {
                            name: "punctuation.section.parens.end.bracket.round.c"
                        }
                    },
                    patterns: [
                        {
                            include: "#function-call-innards-c"
                        }
                    ]
                },
                {
                    include: "#block_innards-c"
                }
            ]
        }
    }
}


def convertAndSaveToJson(hash_obj, json_file_location)
    new_file = File.open(json_file_location, "w")
    new_file.write(hash_obj.to_json)
    new_file.close
end

# Save
convertAndSaveToJson(cpp_grammar, "./syntaxes/cpp.tmLanguage.json")