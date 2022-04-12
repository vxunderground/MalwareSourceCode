/*
 * This file is part of the Process Hacker project - https://processhacker.sourceforge.io/
 *
 * You can redistribute this file and/or modify it under the terms of the 
 * Attribution 4.0 International (CC BY 4.0) license. 
 * 
 * You must give appropriate credit, provide a link to the license, and 
 * indicate if changes were made. You may do so in any reasonable manner, but 
 * not in any way that suggests the licensor endorses you or your use.
 */

#ifndef _NTSAM_H
#define _NTSAM_H

#define SAM_MAXIMUM_LOOKUP_COUNT (1000)
#define SAM_MAXIMUM_LOOKUP_LENGTH (32000)
#define SAM_MAX_PASSWORD_LENGTH (256)
#define SAM_PASSWORD_ENCRYPTION_SALT_LEN (16)

typedef PVOID SAM_HANDLE, *PSAM_HANDLE;
typedef ULONG SAM_ENUMERATE_HANDLE, *PSAM_ENUMERATE_HANDLE;

typedef struct _SAM_RID_ENUMERATION
{
    ULONG RelativeId;
    UNICODE_STRING Name;
} SAM_RID_ENUMERATION, *PSAM_RID_ENUMERATION;

typedef struct _SAM_SID_ENUMERATION
{
    PSID Sid;
    UNICODE_STRING Name;
} SAM_SID_ENUMERATION, *PSAM_SID_ENUMERATION;

typedef struct _SAM_BYTE_ARRAY
{
    ULONG Size;
    _Field_size_bytes_(Size) PUCHAR Data;
} SAM_BYTE_ARRAY, *PSAM_BYTE_ARRAY;

typedef struct _SAM_BYTE_ARRAY_32K
{
    ULONG Size;
    _Field_size_bytes_(Size) PUCHAR Data;
} SAM_BYTE_ARRAY_32K, *PSAM_BYTE_ARRAY_32K;

typedef SAM_BYTE_ARRAY_32K SAM_SHELL_OBJECT_PROPERTIES, *PSAM_SHELL_OBJECT_PROPERTIES;

// Basic

NTSTATUS
NTAPI
SamFreeMemory(
    _In_ PVOID Buffer
    );

NTSTATUS
NTAPI
SamCloseHandle(
    _In_ SAM_HANDLE SamHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamSetSecurityObject(
    _In_ SAM_HANDLE ObjectHandle,
    _In_ SECURITY_INFORMATION SecurityInformation,
    _In_ PSECURITY_DESCRIPTOR SecurityDescriptor
    );

_Check_return_
NTSTATUS
NTAPI
SamQuerySecurityObject(
    _In_ SAM_HANDLE ObjectHandle,
    _In_ SECURITY_INFORMATION SecurityInformation,
    _Outptr_ PSECURITY_DESCRIPTOR *SecurityDescriptor
    );

_Check_return_
NTSTATUS
NTAPI
SamRidToSid(
    _In_ SAM_HANDLE ObjectHandle,
    _In_ ULONG Rid,
    _Outptr_ PSID *Sid
    );

// Server

#define SAM_SERVER_CONNECT 0x0001
#define SAM_SERVER_SHUTDOWN 0x0002
#define SAM_SERVER_INITIALIZE 0x0004
#define SAM_SERVER_CREATE_DOMAIN 0x0008
#define SAM_SERVER_ENUMERATE_DOMAINS 0x0010
#define SAM_SERVER_LOOKUP_DOMAIN 0x0020

#define SAM_SERVER_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED     | \
    SAM_SERVER_CONNECT | \
    SAM_SERVER_INITIALIZE | \
    SAM_SERVER_CREATE_DOMAIN | \
    SAM_SERVER_SHUTDOWN | \
    SAM_SERVER_ENUMERATE_DOMAINS | \
    SAM_SERVER_LOOKUP_DOMAIN)

#define SAM_SERVER_READ (STANDARD_RIGHTS_READ | \
    SAM_SERVER_ENUMERATE_DOMAINS)

#define SAM_SERVER_WRITE (STANDARD_RIGHTS_WRITE | \
    SAM_SERVER_INITIALIZE | \
    SAM_SERVER_CREATE_DOMAIN | \
    SAM_SERVER_SHUTDOWN)

#define SAM_SERVER_EXECUTE (STANDARD_RIGHTS_EXECUTE | \
    SAM_SERVER_CONNECT | \
    SAM_SERVER_LOOKUP_DOMAIN)

// Functions

_Check_return_
NTSTATUS
NTAPI
SamConnect(
    _In_opt_ PUNICODE_STRING ServerName,
    _Out_ PSAM_HANDLE ServerHandle,
    _In_ ACCESS_MASK DesiredAccess,
    _In_ POBJECT_ATTRIBUTES ObjectAttributes
    );

_Check_return_
NTSTATUS
NTAPI
SamShutdownSamServer(
    _In_ SAM_HANDLE ServerHandle
    );

// Domain

#define DOMAIN_READ_PASSWORD_PARAMETERS 0x0001
#define DOMAIN_WRITE_PASSWORD_PARAMS 0x0002
#define DOMAIN_READ_OTHER_PARAMETERS 0x0004
#define DOMAIN_WRITE_OTHER_PARAMETERS 0x0008
#define DOMAIN_CREATE_USER 0x0010
#define DOMAIN_CREATE_GROUP 0x0020
#define DOMAIN_CREATE_ALIAS 0x0040
#define DOMAIN_GET_ALIAS_MEMBERSHIP 0x0080
#define DOMAIN_LIST_ACCOUNTS 0x0100
#define DOMAIN_LOOKUP 0x0200
#define DOMAIN_ADMINISTER_SERVER 0x0400

#define DOMAIN_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | \
    DOMAIN_READ_OTHER_PARAMETERS | \
    DOMAIN_WRITE_OTHER_PARAMETERS | \
    DOMAIN_WRITE_PASSWORD_PARAMS | \
    DOMAIN_CREATE_USER | \
    DOMAIN_CREATE_GROUP | \
    DOMAIN_CREATE_ALIAS | \
    DOMAIN_GET_ALIAS_MEMBERSHIP | \
    DOMAIN_LIST_ACCOUNTS | \
    DOMAIN_READ_PASSWORD_PARAMETERS | \
    DOMAIN_LOOKUP | \
    DOMAIN_ADMINISTER_SERVER)

#define DOMAIN_READ (STANDARD_RIGHTS_READ | \
    DOMAIN_GET_ALIAS_MEMBERSHIP | \
    DOMAIN_READ_OTHER_PARAMETERS)

#define DOMAIN_WRITE (STANDARD_RIGHTS_WRITE | \
    DOMAIN_WRITE_OTHER_PARAMETERS | \
    DOMAIN_WRITE_PASSWORD_PARAMS | \
    DOMAIN_CREATE_USER | \
    DOMAIN_CREATE_GROUP | \
    DOMAIN_CREATE_ALIAS | \
    DOMAIN_ADMINISTER_SERVER)

#define DOMAIN_EXECUTE (STANDARD_RIGHTS_EXECUTE | \
    DOMAIN_READ_PASSWORD_PARAMETERS | \
    DOMAIN_LIST_ACCOUNTS | \
    DOMAIN_LOOKUP)

#define DOMAIN_PROMOTION_INCREMENT { 0x0, 0x10 }
#define DOMAIN_PROMOTION_MASK { 0x0, 0xfffffff0 }

// SamQueryInformationDomain/SamSetInformationDomain types

typedef enum _DOMAIN_INFORMATION_CLASS
{
    DomainPasswordInformation = 1,
    DomainGeneralInformation,
    DomainLogoffInformation,
    DomainOemInformation,
    DomainNameInformation,
    DomainReplicationInformation,
    DomainServerRoleInformation,
    DomainModifiedInformation,
    DomainStateInformation,
    DomainUasInformation,
    DomainGeneralInformation2,
    DomainLockoutInformation,
    DomainModifiedInformation2
} DOMAIN_INFORMATION_CLASS;

typedef enum _DOMAIN_SERVER_ENABLE_STATE
{
    DomainServerEnabled = 1,
    DomainServerDisabled
} DOMAIN_SERVER_ENABLE_STATE, *PDOMAIN_SERVER_ENABLE_STATE;

typedef enum _DOMAIN_SERVER_ROLE
{
    DomainServerRoleBackup = 2,
    DomainServerRolePrimary
} DOMAIN_SERVER_ROLE, *PDOMAIN_SERVER_ROLE;

#include <pshpack4.h>
typedef struct _DOMAIN_GENERAL_INFORMATION
{
    LARGE_INTEGER ForceLogoff;
    UNICODE_STRING OemInformation;
    UNICODE_STRING DomainName;
    UNICODE_STRING ReplicaSourceNodeName;
    LARGE_INTEGER DomainModifiedCount;
    DOMAIN_SERVER_ENABLE_STATE DomainServerState;
    DOMAIN_SERVER_ROLE DomainServerRole;
    BOOLEAN UasCompatibilityRequired;
    ULONG UserCount;
    ULONG GroupCount;
    ULONG AliasCount;
} DOMAIN_GENERAL_INFORMATION, *PDOMAIN_GENERAL_INFORMATION;
#include <poppack.h>

#include <pshpack4.h>
typedef struct _DOMAIN_GENERAL_INFORMATION2
{
    DOMAIN_GENERAL_INFORMATION I1;
    LARGE_INTEGER LockoutDuration; // delta time
    LARGE_INTEGER LockoutObservationWindow; // delta time
    USHORT LockoutThreshold;
} DOMAIN_GENERAL_INFORMATION2, *PDOMAIN_GENERAL_INFORMATION2;
#include <poppack.h>

typedef struct _DOMAIN_UAS_INFORMATION
{
    BOOLEAN UasCompatibilityRequired;
} DOMAIN_UAS_INFORMATION;

#ifndef _DOMAIN_PASSWORD_INFORMATION_DEFINED // defined in ntsecapi.h
#define _DOMAIN_PASSWORD_INFORMATION_DEFINED

typedef struct _DOMAIN_PASSWORD_INFORMATION
{
    USHORT MinPasswordLength;
    USHORT PasswordHistoryLength;
    ULONG PasswordProperties;
    LARGE_INTEGER MaxPasswordAge;
    LARGE_INTEGER MinPasswordAge;
} DOMAIN_PASSWORD_INFORMATION, *PDOMAIN_PASSWORD_INFORMATION;

// PasswordProperties flags

#define DOMAIN_PASSWORD_COMPLEX 0x00000001L
#define DOMAIN_PASSWORD_NO_ANON_CHANGE 0x00000002L
#define DOMAIN_PASSWORD_NO_CLEAR_CHANGE 0x00000004L
#define DOMAIN_LOCKOUT_ADMINS 0x00000008L
#define DOMAIN_PASSWORD_STORE_CLEARTEXT 0x00000010L
#define DOMAIN_REFUSE_PASSWORD_CHANGE 0x00000020L
#define DOMAIN_NO_LM_OWF_CHANGE 0x00000040L

#endif

typedef enum _DOMAIN_PASSWORD_CONSTRUCTION
{
    DomainPasswordSimple = 1,
    DomainPasswordComplex
} DOMAIN_PASSWORD_CONSTRUCTION;

typedef struct _DOMAIN_LOGOFF_INFORMATION
{
    LARGE_INTEGER ForceLogoff;
} DOMAIN_LOGOFF_INFORMATION, *PDOMAIN_LOGOFF_INFORMATION;

typedef struct _DOMAIN_OEM_INFORMATION
{
    UNICODE_STRING OemInformation;
} DOMAIN_OEM_INFORMATION, *PDOMAIN_OEM_INFORMATION;

typedef struct _DOMAIN_NAME_INFORMATION
{
    UNICODE_STRING DomainName;
} DOMAIN_NAME_INFORMATION, *PDOMAIN_NAME_INFORMATION;

typedef struct _DOMAIN_SERVER_ROLE_INFORMATION
{
    DOMAIN_SERVER_ROLE DomainServerRole;
} DOMAIN_SERVER_ROLE_INFORMATION, *PDOMAIN_SERVER_ROLE_INFORMATION;

typedef struct _DOMAIN_REPLICATION_INFORMATION
{
    UNICODE_STRING ReplicaSourceNodeName;
} DOMAIN_REPLICATION_INFORMATION, *PDOMAIN_REPLICATION_INFORMATION;

typedef struct _DOMAIN_MODIFIED_INFORMATION
{
    LARGE_INTEGER DomainModifiedCount;
    LARGE_INTEGER CreationTime;
} DOMAIN_MODIFIED_INFORMATION, *PDOMAIN_MODIFIED_INFORMATION;

typedef struct _DOMAIN_MODIFIED_INFORMATION2
{
    LARGE_INTEGER DomainModifiedCount;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER ModifiedCountAtLastPromotion;
} DOMAIN_MODIFIED_INFORMATION2, *PDOMAIN_MODIFIED_INFORMATION2;

typedef struct _DOMAIN_STATE_INFORMATION
{
    DOMAIN_SERVER_ENABLE_STATE DomainServerState;
} DOMAIN_STATE_INFORMATION, *PDOMAIN_STATE_INFORMATION;

typedef struct _DOMAIN_LOCKOUT_INFORMATION
{
    LARGE_INTEGER LockoutDuration; // delta time
    LARGE_INTEGER LockoutObservationWindow; // delta time
    USHORT LockoutThreshold; // zero means no lockout
} DOMAIN_LOCKOUT_INFORMATION, *PDOMAIN_LOCKOUT_INFORMATION;

// SamQueryDisplayInformation types

typedef enum _DOMAIN_DISPLAY_INFORMATION
{
    DomainDisplayUser = 1,
    DomainDisplayMachine,
    DomainDisplayGroup,
    DomainDisplayOemUser,
    DomainDisplayOemGroup,
    DomainDisplayServer
} DOMAIN_DISPLAY_INFORMATION, *PDOMAIN_DISPLAY_INFORMATION;

typedef struct _DOMAIN_DISPLAY_USER
{
    ULONG Index;
    ULONG Rid;
    ULONG AccountControl;
    UNICODE_STRING LogonName;
    UNICODE_STRING AdminComment;
    UNICODE_STRING FullName;
} DOMAIN_DISPLAY_USER, *PDOMAIN_DISPLAY_USER;

typedef struct _DOMAIN_DISPLAY_MACHINE
{
    ULONG Index;
    ULONG Rid;
    ULONG AccountControl;
    UNICODE_STRING Machine;
    UNICODE_STRING Comment;
} DOMAIN_DISPLAY_MACHINE, *PDOMAIN_DISPLAY_MACHINE;

typedef struct _DOMAIN_DISPLAY_GROUP
{
    ULONG Index;
    ULONG Rid;
    ULONG Attributes;
    UNICODE_STRING Group;
    UNICODE_STRING Comment;
} DOMAIN_DISPLAY_GROUP, *PDOMAIN_DISPLAY_GROUP;

typedef struct _DOMAIN_DISPLAY_OEM_USER
{
    ULONG Index;
    OEM_STRING User;
} DOMAIN_DISPLAY_OEM_USER, *PDOMAIN_DISPLAY_OEM_USER;

typedef struct _DOMAIN_DISPLAY_OEM_GROUP
{
    ULONG Index;
    OEM_STRING Group;
} DOMAIN_DISPLAY_OEM_GROUP, *PDOMAIN_DISPLAY_OEM_GROUP;

// SamQueryLocalizableAccountsInDomain types

typedef enum _DOMAIN_LOCALIZABLE_ACCOUNTS_INFORMATION
{
    DomainLocalizableAccountsBasic = 1,
} DOMAIN_LOCALIZABLE_ACCOUNTS_INFORMATION, *PDOMAIN_LOCALIZABLE_ACCOUNTS_INFORMATION;

typedef struct _DOMAIN_LOCALIZABLE_ACCOUNTS_ENTRY
{
    ULONG Rid;
    SID_NAME_USE Use;
    UNICODE_STRING Name;
    UNICODE_STRING AdminComment;
} DOMAIN_LOCALIZABLE_ACCOUNT_ENTRY, *PDOMAIN_LOCALIZABLE_ACCOUNT_ENTRY;

typedef struct _DOMAIN_LOCALIZABLE_ACCOUNTS
{
    ULONG Count;
    _Field_size_(Count) DOMAIN_LOCALIZABLE_ACCOUNT_ENTRY *Entries;
} DOMAIN_LOCALIZABLE_ACCOUNTS_BASIC, *PDOMAIN_LOCALIZABLE_ACCOUNTS_BASIC;

typedef union _DOMAIN_LOCALIZABLE_INFO_BUFFER
{
    DOMAIN_LOCALIZABLE_ACCOUNTS_BASIC Basic;
} DOMAIN_LOCALIZABLE_ACCOUNTS_INFO_BUFFER, *PDOMAIN_LOCALIZABLE_ACCOUNTS_INFO_BUFFER;

// Functions

_Check_return_
NTSTATUS
NTAPI
SamLookupDomainInSamServer(
    _In_ SAM_HANDLE ServerHandle,
    _In_ PUNICODE_STRING Name,
    _Outptr_ PSID *DomainId
    );

_Check_return_
NTSTATUS
NTAPI
SamEnumerateDomainsInSamServer(
    _In_ SAM_HANDLE ServerHandle,
    _Inout_ PSAM_ENUMERATE_HANDLE EnumerationContext,
    _Outptr_ PVOID *Buffer, // PSAM_SID_ENUMERATION *Buffer
    _In_ ULONG PreferedMaximumLength,
    _Out_ PULONG CountReturned
    );

_Check_return_
NTSTATUS
NTAPI
SamOpenDomain(
    _In_ SAM_HANDLE ServerHandle,
    _In_ ACCESS_MASK DesiredAccess,
    _In_ PSID DomainId,
    _Out_ PSAM_HANDLE DomainHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryInformationDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ DOMAIN_INFORMATION_CLASS DomainInformationClass,
    _Outptr_ PVOID *Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamSetInformationDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ DOMAIN_INFORMATION_CLASS DomainInformationClass,
    _In_ PVOID DomainInformation
    );

_Check_return_
NTSTATUS
NTAPI
SamLookupNamesInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ULONG Count,
    _In_reads_(Count) PUNICODE_STRING Names,
    _Out_ _Deref_post_count_(Count) PULONG *RelativeIds,
    _Out_ _Deref_post_count_(Count) PSID_NAME_USE *Use
    );

_Check_return_
NTSTATUS
NTAPI
SamLookupIdsInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ULONG Count,
    _In_reads_(Count) PULONG RelativeIds,
    _Out_ _Deref_post_count_(Count) PUNICODE_STRING *Names,
    _Out_ _Deref_post_opt_count_(Count) PSID_NAME_USE *Use
    );

_Check_return_
NTSTATUS
NTAPI
SamRemoveMemberFromForeignDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ PSID MemberId
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryLocalizableAccountsInDomain(
    _In_ SAM_HANDLE Domain,
    _In_ ULONG Flags,
    _In_ ULONG LanguageId,
    _In_ DOMAIN_LOCALIZABLE_ACCOUNTS_INFORMATION Class,
    _Outptr_ PVOID *Buffer
    );

// Group

#define GROUP_READ_INFORMATION 0x0001
#define GROUP_WRITE_ACCOUNT 0x0002
#define GROUP_ADD_MEMBER 0x0004
#define GROUP_REMOVE_MEMBER 0x0008
#define GROUP_LIST_MEMBERS 0x0010

#define GROUP_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | \
    GROUP_LIST_MEMBERS | \
    GROUP_WRITE_ACCOUNT | \
    GROUP_ADD_MEMBER | \
    GROUP_REMOVE_MEMBER | \
    GROUP_READ_INFORMATION)

#define GROUP_READ (STANDARD_RIGHTS_READ | \
    GROUP_LIST_MEMBERS)

#define GROUP_WRITE (STANDARD_RIGHTS_WRITE | \
    GROUP_WRITE_ACCOUNT | \
    GROUP_ADD_MEMBER | \
    GROUP_REMOVE_MEMBER)

#define GROUP_EXECUTE (STANDARD_RIGHTS_EXECUTE | \
    GROUP_READ_INFORMATION)

typedef struct _GROUP_MEMBERSHIP
{
    ULONG RelativeId;
    ULONG Attributes;
} GROUP_MEMBERSHIP, *PGROUP_MEMBERSHIP;

// SamQueryInformationGroup/SamSetInformationGroup types

typedef enum _GROUP_INFORMATION_CLASS
{
    GroupGeneralInformation = 1,
    GroupNameInformation,
    GroupAttributeInformation,
    GroupAdminCommentInformation,
    GroupReplicationInformation
} GROUP_INFORMATION_CLASS;

typedef struct _GROUP_GENERAL_INFORMATION
{
    UNICODE_STRING Name;
    ULONG Attributes;
    ULONG MemberCount;
    UNICODE_STRING AdminComment;
} GROUP_GENERAL_INFORMATION, *PGROUP_GENERAL_INFORMATION;

typedef struct _GROUP_NAME_INFORMATION
{
    UNICODE_STRING Name;
} GROUP_NAME_INFORMATION, *PGROUP_NAME_INFORMATION;

typedef struct _GROUP_ATTRIBUTE_INFORMATION
{
    ULONG Attributes;
} GROUP_ATTRIBUTE_INFORMATION, *PGROUP_ATTRIBUTE_INFORMATION;

typedef struct _GROUP_ADM_COMMENT_INFORMATION
{
    UNICODE_STRING AdminComment;
} GROUP_ADM_COMMENT_INFORMATION, *PGROUP_ADM_COMMENT_INFORMATION;

// Functions

_Check_return_
NTSTATUS
NTAPI
SamEnumerateGroupsInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _Inout_ PSAM_ENUMERATE_HANDLE EnumerationContext,
    _Outptr_ PVOID *Buffer, // PSAM_RID_ENUMERATION *
    _In_ ULONG PreferedMaximumLength,
    _Out_ PULONG CountReturned
    );

_Check_return_
NTSTATUS
NTAPI
SamCreateGroupInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ PUNICODE_STRING AccountName,
    _In_ ACCESS_MASK DesiredAccess,
    _Out_ PSAM_HANDLE GroupHandle,
    _Out_ PULONG RelativeId
    );

_Check_return_
NTSTATUS
NTAPI
SamOpenGroup(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ACCESS_MASK DesiredAccess,
    _In_ ULONG GroupId,
    _Out_ PSAM_HANDLE GroupHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamDeleteGroup(
    _In_ SAM_HANDLE GroupHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryInformationGroup(
    _In_ SAM_HANDLE GroupHandle,
    _In_ GROUP_INFORMATION_CLASS GroupInformationClass,
    _Outptr_ PVOID *Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamSetInformationGroup(
    _In_ SAM_HANDLE GroupHandle,
    _In_ GROUP_INFORMATION_CLASS GroupInformationClass,
    _In_ PVOID Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamAddMemberToGroup(
    _In_ SAM_HANDLE GroupHandle,
    _In_ ULONG MemberId,
    _In_ ULONG Attributes
    );

_Check_return_
NTSTATUS
NTAPI
SamRemoveMemberFromGroup(
    _In_ SAM_HANDLE GroupHandle,
    _In_ ULONG MemberId
    );

_Check_return_
NTSTATUS
NTAPI
SamGetMembersInGroup(
    _In_ SAM_HANDLE GroupHandle,
    _Out_ _Deref_post_count_(*MemberCount) PULONG *MemberIds,
    _Out_ _Deref_post_count_(*MemberCount) PULONG *Attributes,
    _Out_ PULONG MemberCount
    );

_Check_return_
NTSTATUS
NTAPI
SamSetMemberAttributesOfGroup(
    _In_ SAM_HANDLE GroupHandle,
    _In_ ULONG MemberId,
    _In_ ULONG Attributes
    );

// Alias

#define ALIAS_ADD_MEMBER 0x0001
#define ALIAS_REMOVE_MEMBER 0x0002
#define ALIAS_LIST_MEMBERS 0x0004
#define ALIAS_READ_INFORMATION 0x0008
#define ALIAS_WRITE_ACCOUNT 0x0010

#define ALIAS_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | \
    ALIAS_READ_INFORMATION | \
    ALIAS_WRITE_ACCOUNT | \
    ALIAS_LIST_MEMBERS | \
    ALIAS_ADD_MEMBER | \
    ALIAS_REMOVE_MEMBER)

#define ALIAS_READ (STANDARD_RIGHTS_READ | \
    ALIAS_LIST_MEMBERS)

#define ALIAS_WRITE (STANDARD_RIGHTS_WRITE | \
    ALIAS_WRITE_ACCOUNT | \
    ALIAS_ADD_MEMBER | \
    ALIAS_REMOVE_MEMBER)

#define ALIAS_EXECUTE (STANDARD_RIGHTS_EXECUTE | \
    ALIAS_READ_INFORMATION)

// SamQueryInformationAlias/SamSetInformationAlias types

typedef enum _ALIAS_INFORMATION_CLASS
{
    AliasGeneralInformation = 1,
    AliasNameInformation,
    AliasAdminCommentInformation,
    AliasReplicationInformation,
    AliasExtendedInformation,
} ALIAS_INFORMATION_CLASS;

typedef struct _ALIAS_GENERAL_INFORMATION
{
    UNICODE_STRING Name;
    ULONG MemberCount;
    UNICODE_STRING AdminComment;
} ALIAS_GENERAL_INFORMATION,  *PALIAS_GENERAL_INFORMATION;

typedef struct _ALIAS_NAME_INFORMATION
{
    UNICODE_STRING Name;
} ALIAS_NAME_INFORMATION, *PALIAS_NAME_INFORMATION;

typedef struct _ALIAS_ADM_COMMENT_INFORMATION
{
    UNICODE_STRING AdminComment;
} ALIAS_ADM_COMMENT_INFORMATION, *PALIAS_ADM_COMMENT_INFORMATION;

#define ALIAS_ALL_NAME (0x00000001L)
#define ALIAS_ALL_MEMBER_COUNT (0x00000002L)
#define ALIAS_ALL_ADMIN_COMMENT (0x00000004L)
#define ALIAS_ALL_SHELL_ADMIN_OBJECT_PROPERTIES (0x00000008L)

typedef struct _ALIAS_EXTENDED_INFORMATION
{
    ULONG WhichFields;
    SAM_SHELL_OBJECT_PROPERTIES ShellAdminObjectProperties;
} ALIAS_EXTENDED_INFORMATION, *PALIAS_EXTENDED_INFORMATION;

// Functions

_Check_return_
NTSTATUS
NTAPI
SamEnumerateAliasesInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _Inout_ PSAM_ENUMERATE_HANDLE EnumerationContext,
    _Outptr_ PVOID *Buffer, // PSAM_RID_ENUMERATION *Buffer
    _In_ ULONG PreferedMaximumLength,
    _Out_ PULONG CountReturned
    );

_Check_return_
NTSTATUS
NTAPI
SamCreateAliasInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ PUNICODE_STRING AccountName,
    _In_ ACCESS_MASK DesiredAccess,
    _Out_ PSAM_HANDLE AliasHandle,
    _Out_ PULONG RelativeId
    );

_Check_return_
NTSTATUS
NTAPI
SamOpenAlias(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ACCESS_MASK DesiredAccess,
    _In_ ULONG AliasId,
    _Out_ PSAM_HANDLE AliasHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamDeleteAlias(
    _In_ SAM_HANDLE AliasHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryInformationAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_ ALIAS_INFORMATION_CLASS AliasInformationClass,
    _Outptr_ PVOID *Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamSetInformationAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_ ALIAS_INFORMATION_CLASS AliasInformationClass,
    _In_ PVOID Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamAddMemberToAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_ PSID MemberId
    );

_Check_return_
NTSTATUS
NTAPI
SamAddMultipleMembersToAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_reads_(MemberCount) PSID *MemberIds,
    _In_ ULONG MemberCount
    );

_Check_return_
NTSTATUS
NTAPI
SamRemoveMemberFromAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_ PSID MemberId
    );

_Check_return_
NTSTATUS
NTAPI
SamRemoveMultipleMembersFromAlias(
    _In_ SAM_HANDLE AliasHandle,
    _In_reads_(MemberCount) PSID *MemberIds,
    _In_ ULONG MemberCount
    );

_Check_return_
NTSTATUS
NTAPI
SamGetMembersInAlias(
    _In_ SAM_HANDLE AliasHandle,
    _Out_ _Deref_post_count_(*MemberCount) PSID **MemberIds,
    _Out_ PULONG MemberCount
    );

_Check_return_
NTSTATUS
NTAPI
SamGetAliasMembership(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ULONG PassedCount,
    _In_reads_(PassedCount) PSID *Sids,
    _Out_ PULONG MembershipCount,
    _Out_ _Deref_post_count_(*MembershipCount) PULONG *Aliases
    );

// Group types

#define GROUP_TYPE_BUILTIN_LOCAL_GROUP 0x00000001
#define GROUP_TYPE_ACCOUNT_GROUP 0x00000002
#define GROUP_TYPE_RESOURCE_GROUP 0x00000004
#define GROUP_TYPE_UNIVERSAL_GROUP 0x00000008
#define GROUP_TYPE_APP_BASIC_GROUP 0x00000010
#define GROUP_TYPE_APP_QUERY_GROUP 0x00000020
#define GROUP_TYPE_SECURITY_ENABLED 0x80000000

#define GROUP_TYPE_RESOURCE_BEHAVOIR (GROUP_TYPE_RESOURCE_GROUP | \
    GROUP_TYPE_APP_BASIC_GROUP | \
    GROUP_TYPE_APP_QUERY_GROUP)

// User

#define USER_READ_GENERAL 0x0001
#define USER_READ_PREFERENCES 0x0002
#define USER_WRITE_PREFERENCES 0x0004
#define USER_READ_LOGON 0x0008
#define USER_READ_ACCOUNT 0x0010
#define USER_WRITE_ACCOUNT 0x0020
#define USER_CHANGE_PASSWORD 0x0040
#define USER_FORCE_PASSWORD_CHANGE 0x0080
#define USER_LIST_GROUPS 0x0100
#define USER_READ_GROUP_INFORMATION 0x0200
#define USER_WRITE_GROUP_INFORMATION 0x0400

#define USER_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | \
    USER_READ_PREFERENCES | \
    USER_READ_LOGON | \
    USER_LIST_GROUPS | \
    USER_READ_GROUP_INFORMATION | \
    USER_WRITE_PREFERENCES | \
    USER_CHANGE_PASSWORD | \
    USER_FORCE_PASSWORD_CHANGE | \
    USER_READ_GENERAL | \
    USER_READ_ACCOUNT | \
    USER_WRITE_ACCOUNT | \
    USER_WRITE_GROUP_INFORMATION)

#define USER_READ (STANDARD_RIGHTS_READ | \
    USER_READ_PREFERENCES | \
    USER_READ_LOGON | \
    USER_READ_ACCOUNT | \
    USER_LIST_GROUPS | \
    USER_READ_GROUP_INFORMATION)

#define USER_WRITE (STANDARD_RIGHTS_WRITE | \
    USER_WRITE_PREFERENCES | \
    USER_CHANGE_PASSWORD)

#define USER_EXECUTE (STANDARD_RIGHTS_EXECUTE | \
    USER_READ_GENERAL | \
    USER_CHANGE_PASSWORD)

// User account control flags

#define USER_ACCOUNT_DISABLED (0x00000001)
#define USER_HOME_DIRECTORY_REQUIRED (0x00000002)
#define USER_PASSWORD_NOT_REQUIRED (0x00000004)
#define USER_TEMP_DUPLICATE_ACCOUNT (0x00000008)
#define USER_NORMAL_ACCOUNT (0x00000010)
#define USER_MNS_LOGON_ACCOUNT (0x00000020)
#define USER_INTERDOMAIN_TRUST_ACCOUNT (0x00000040)
#define USER_WORKSTATION_TRUST_ACCOUNT (0x00000080)
#define USER_SERVER_TRUST_ACCOUNT (0x00000100)
#define USER_DONT_EXPIRE_PASSWORD (0x00000200)
#define USER_ACCOUNT_AUTO_LOCKED (0x00000400)
#define USER_ENCRYPTED_TEXT_PASSWORD_ALLOWED (0x00000800)
#define USER_SMARTCARD_REQUIRED (0x00001000)
#define USER_TRUSTED_FOR_DELEGATION (0x00002000)
#define USER_NOT_DELEGATED (0x00004000)
#define USER_USE_DES_KEY_ONLY (0x00008000)
#define USER_DONT_REQUIRE_PREAUTH (0x00010000)
#define USER_PASSWORD_EXPIRED (0x00020000)
#define USER_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION (0x00040000)
#define USER_NO_AUTH_DATA_REQUIRED (0x00080000)
#define USER_PARTIAL_SECRETS_ACCOUNT (0x00100000)
#define USER_USE_AES_KEYS (0x00200000) // not used

#define NEXT_FREE_ACCOUNT_CONTROL_BIT (USER_USE_AES_KEYS << 1)

#define USER_MACHINE_ACCOUNT_MASK ( \
    USER_INTERDOMAIN_TRUST_ACCOUNT | \
    USER_WORKSTATION_TRUST_ACCOUNT | \
    USER_SERVER_TRUST_ACCOUNT \
    )

#define USER_ACCOUNT_TYPE_MASK ( \
    USER_TEMP_DUPLICATE_ACCOUNT | \
    USER_NORMAL_ACCOUNT | \
    USER_MACHINE_ACCOUNT_MASK \
    )

#define USER_COMPUTED_ACCOUNT_CONTROL_BITS ( \
    USER_ACCOUNT_AUTO_LOCKED | \
    USER_PASSWORD_EXPIRED \
    )

// Logon times may be expressed in day, hour, or minute granularity.

#define SAM_DAYS_PER_WEEK (7)
#define SAM_HOURS_PER_WEEK (24 * SAM_DAYS_PER_WEEK)
#define SAM_MINUTES_PER_WEEK (60 * SAM_HOURS_PER_WEEK)

typedef struct _LOGON_HOURS
{
    USHORT UnitsPerWeek;

    // UnitsPerWeek is the number of equal length time units the week is
    // divided into. This value is used to compute the length of the bit
    // string in logon_hours. Must be less than or equal to
    // SAM_UNITS_PER_WEEK (10080) for this release.
    //
    // LogonHours is a bit map of valid logon times. Each bit represents
    // a unique division in a week. The largest bit map supported is 1260
    // bytes (10080 bits), which represents minutes per week. In this case
    // the first bit (bit 0, byte 0) is Sunday, 00:00:00 - 00-00:59; bit 1,
    // byte 0 is Sunday, 00:01:00 - 00:01:59, etc. A NULL pointer means
    // DONT_CHANGE for SamSetInformationUser() calls.

    PUCHAR LogonHours;
} LOGON_HOURS, *PLOGON_HOURS;

typedef struct _SR_SECURITY_DESCRIPTOR
{
    ULONG Length;
    PUCHAR SecurityDescriptor;
} SR_SECURITY_DESCRIPTOR, *PSR_SECURITY_DESCRIPTOR;

// SamQueryInformationUser/SamSetInformationUser types

typedef enum _USER_INFORMATION_CLASS
{
    UserGeneralInformation = 1, // USER_GENERAL_INFORMATION
    UserPreferencesInformation, // USER_PREFERENCES_INFORMATION
    UserLogonInformation, // USER_LOGON_INFORMATION
    UserLogonHoursInformation, // USER_LOGON_HOURS_INFORMATION
    UserAccountInformation, // USER_ACCOUNT_INFORMATION
    UserNameInformation, // USER_NAME_INFORMATION
    UserAccountNameInformation, // USER_ACCOUNT_NAME_INFORMATION
    UserFullNameInformation, // USER_FULL_NAME_INFORMATION
    UserPrimaryGroupInformation, // USER_PRIMARY_GROUP_INFORMATION
    UserHomeInformation, // USER_HOME_INFORMATION
    UserScriptInformation, // USER_SCRIPT_INFORMATION
    UserProfileInformation, // USER_PROFILE_INFORMATION
    UserAdminCommentInformation, // USER_ADMIN_COMMENT_INFORMATION
    UserWorkStationsInformation, // USER_WORKSTATIONS_INFORMATION
    UserSetPasswordInformation, // USER_SET_PASSWORD_INFORMATION
    UserControlInformation, // USER_CONTROL_INFORMATION
    UserExpiresInformation, // USER_EXPIRES_INFORMATION
    UserInternal1Information,
    UserInternal2Information,
    UserParametersInformation, // USER_PARAMETERS_INFORMATION
    UserAllInformation, // USER_ALL_INFORMATION
    UserInternal3Information,
    UserInternal4Information,
    UserInternal5Information,
    UserInternal4InformationNew,
    UserInternal5InformationNew,
    UserInternal6Information,
    UserExtendedInformation, // USER_EXTENDED_INFORMATION
    UserLogonUIInformation // USER_LOGON_UI_INFORMATION
} USER_INFORMATION_CLASS, *PUSER_INFORMATION_CLASS;

typedef struct _USER_GENERAL_INFORMATION
{
    UNICODE_STRING UserName;
    UNICODE_STRING FullName;
    ULONG PrimaryGroupId;
    UNICODE_STRING AdminComment;
    UNICODE_STRING UserComment;
} USER_GENERAL_INFORMATION, *PUSER_GENERAL_INFORMATION;

typedef struct _USER_PREFERENCES_INFORMATION
{
    UNICODE_STRING UserComment;
    UNICODE_STRING Reserved1;
    USHORT CountryCode;
    USHORT CodePage;
} USER_PREFERENCES_INFORMATION, *PUSER_PREFERENCES_INFORMATION;

#include <pshpack4.h>
typedef struct _USER_LOGON_INFORMATION
{
    UNICODE_STRING UserName;
    UNICODE_STRING FullName;
    ULONG UserId;
    ULONG PrimaryGroupId;
    UNICODE_STRING HomeDirectory;
    UNICODE_STRING HomeDirectoryDrive;
    UNICODE_STRING ScriptPath;
    UNICODE_STRING ProfilePath;
    UNICODE_STRING WorkStations;
    LARGE_INTEGER LastLogon;
    LARGE_INTEGER LastLogoff;
    LARGE_INTEGER PasswordLastSet;
    LARGE_INTEGER PasswordCanChange;
    LARGE_INTEGER PasswordMustChange;
    LOGON_HOURS LogonHours;
    USHORT BadPasswordCount;
    USHORT LogonCount;
    ULONG UserAccountControl;
} USER_LOGON_INFORMATION, * PUSER_LOGON_INFORMATION;
#include <poppack.h>

typedef struct _USER_LOGON_HOURS_INFORMATION
{
    LOGON_HOURS LogonHours;
} USER_LOGON_HOURS_INFORMATION, * PUSER_LOGON_HOURS_INFORMATION;

#include <pshpack4.h>
typedef struct _USER_ACCOUNT_INFORMATION
{
    UNICODE_STRING UserName;
    UNICODE_STRING FullName;
    ULONG UserId;
    ULONG PrimaryGroupId;
    UNICODE_STRING HomeDirectory;
    UNICODE_STRING HomeDirectoryDrive;
    UNICODE_STRING ScriptPath;
    UNICODE_STRING ProfilePath;
    UNICODE_STRING AdminComment;
    UNICODE_STRING WorkStations;
    LARGE_INTEGER LastLogon;
    LARGE_INTEGER LastLogoff;
    LOGON_HOURS LogonHours;
    USHORT BadPasswordCount;
    USHORT LogonCount;
    LARGE_INTEGER PasswordLastSet;
    LARGE_INTEGER AccountExpires;
    ULONG UserAccountControl;
} USER_ACCOUNT_INFORMATION, * PUSER_ACCOUNT_INFORMATION;
#include <poppack.h>

typedef struct _USER_NAME_INFORMATION
{
    UNICODE_STRING UserName;
    UNICODE_STRING FullName;
} USER_NAME_INFORMATION, *PUSER_NAME_INFORMATION;

typedef struct _USER_ACCOUNT_NAME_INFORMATION
{
    UNICODE_STRING UserName;
} USER_ACCOUNT_NAME_INFORMATION, *PUSER_ACCOUNT_NAME_INFORMATION;

typedef struct _USER_FULL_NAME_INFORMATION
{
    UNICODE_STRING FullName;
} USER_FULL_NAME_INFORMATION, *PUSER_FULL_NAME_INFORMATION;

typedef struct _USER_PRIMARY_GROUP_INFORMATION
{
    ULONG PrimaryGroupId;
} USER_PRIMARY_GROUP_INFORMATION, *PUSER_PRIMARY_GROUP_INFORMATION;

typedef struct _USER_HOME_INFORMATION
{
    UNICODE_STRING HomeDirectory;
    UNICODE_STRING HomeDirectoryDrive;
} USER_HOME_INFORMATION, *PUSER_HOME_INFORMATION;

typedef struct _USER_SCRIPT_INFORMATION
{
    UNICODE_STRING ScriptPath;
} USER_SCRIPT_INFORMATION, *PUSER_SCRIPT_INFORMATION;

typedef struct _USER_PROFILE_INFORMATION
{
    UNICODE_STRING ProfilePath;
} USER_PROFILE_INFORMATION, *PUSER_PROFILE_INFORMATION;

typedef struct _USER_ADMIN_COMMENT_INFORMATION
{
    UNICODE_STRING AdminComment;
} USER_ADMIN_COMMENT_INFORMATION, *PUSER_ADMIN_COMMENT_INFORMATION;

typedef struct _USER_WORKSTATIONS_INFORMATION
{
    UNICODE_STRING WorkStations;
} USER_WORKSTATIONS_INFORMATION, *PUSER_WORKSTATIONS_INFORMATION;

typedef struct _USER_SET_PASSWORD_INFORMATION
{
    UNICODE_STRING Password;
    BOOLEAN PasswordExpired;
} USER_SET_PASSWORD_INFORMATION, *PUSER_SET_PASSWORD_INFORMATION;

typedef struct _USER_CONTROL_INFORMATION
{
    ULONG UserAccountControl;
} USER_CONTROL_INFORMATION, *PUSER_CONTROL_INFORMATION;

typedef struct _USER_EXPIRES_INFORMATION
{
    LARGE_INTEGER AccountExpires;
} USER_EXPIRES_INFORMATION, *PUSER_EXPIRES_INFORMATION;

typedef struct _USER_PARAMETERS_INFORMATION
{
    UNICODE_STRING Parameters;
} USER_PARAMETERS_INFORMATION, *PUSER_PARAMETERS_INFORMATION;

// Flags for WhichFields in USER_ALL_INFORMATION

#define USER_ALL_USERNAME 0x00000001
#define USER_ALL_FULLNAME 0x00000002
#define USER_ALL_USERID 0x00000004
#define USER_ALL_PRIMARYGROUPID 0x00000008
#define USER_ALL_ADMINCOMMENT 0x00000010
#define USER_ALL_USERCOMMENT 0x00000020
#define USER_ALL_HOMEDIRECTORY 0x00000040
#define USER_ALL_HOMEDIRECTORYDRIVE 0x00000080
#define USER_ALL_SCRIPTPATH 0x00000100
#define USER_ALL_PROFILEPATH 0x00000200
#define USER_ALL_WORKSTATIONS 0x00000400
#define USER_ALL_LASTLOGON 0x00000800
#define USER_ALL_LASTLOGOFF 0x00001000
#define USER_ALL_LOGONHOURS 0x00002000
#define USER_ALL_BADPASSWORDCOUNT 0x00004000
#define USER_ALL_LOGONCOUNT 0x00008000
#define USER_ALL_PASSWORDCANCHANGE 0x00010000
#define USER_ALL_PASSWORDMUSTCHANGE 0x00020000
#define USER_ALL_PASSWORDLASTSET 0x00040000
#define USER_ALL_ACCOUNTEXPIRES 0x00080000
#define USER_ALL_USERACCOUNTCONTROL 0x00100000
#define USER_ALL_PARAMETERS 0x00200000
#define USER_ALL_COUNTRYCODE 0x00400000
#define USER_ALL_CODEPAGE 0x00800000
#define USER_ALL_NTPASSWORDPRESENT 0x01000000 // field AND boolean
#define USER_ALL_LMPASSWORDPRESENT 0x02000000 // field AND boolean
#define USER_ALL_PRIVATEDATA 0x04000000 // field AND boolean
#define USER_ALL_PASSWORDEXPIRED 0x08000000
#define USER_ALL_SECURITYDESCRIPTOR 0x10000000
#define USER_ALL_OWFPASSWORD 0x20000000 // boolean

#define USER_ALL_UNDEFINED_MASK 0xc0000000

// Fields that require USER_READ_GENERAL access to read.

#define USER_ALL_READ_GENERAL_MASK \
    (USER_ALL_USERNAME | \
    USER_ALL_FULLNAME | \
    USER_ALL_USERID | \
    USER_ALL_PRIMARYGROUPID | \
    USER_ALL_ADMINCOMMENT | \
    USER_ALL_USERCOMMENT)

// Fields that require USER_READ_LOGON access to read.

#define USER_ALL_READ_LOGON_MASK \
   (USER_ALL_HOMEDIRECTORY | \
    USER_ALL_HOMEDIRECTORYDRIVE | \
    USER_ALL_SCRIPTPATH | \
    USER_ALL_PROFILEPATH | \
    USER_ALL_WORKSTATIONS | \
    USER_ALL_LASTLOGON | \
    USER_ALL_LASTLOGOFF | \
    USER_ALL_LOGONHOURS | \
    USER_ALL_BADPASSWORDCOUNT | \
    USER_ALL_LOGONCOUNT | \
    USER_ALL_PASSWORDCANCHANGE | \
    USER_ALL_PASSWORDMUSTCHANGE)

// Fields that require USER_READ_ACCOUNT access to read.

#define USER_ALL_READ_ACCOUNT_MASK \
    (USER_ALL_PASSWORDLASTSET | \
    USER_ALL_ACCOUNTEXPIRES | \
    USER_ALL_USERACCOUNTCONTROL | \
    USER_ALL_PARAMETERS)

// Fields that require USER_READ_PREFERENCES access to read.

#define USER_ALL_READ_PREFERENCES_MASK \
    (USER_ALL_COUNTRYCODE | USER_ALL_CODEPAGE)

// Fields that can only be read by trusted clients.

#define USER_ALL_READ_TRUSTED_MASK \
    (USER_ALL_NTPASSWORDPRESENT | \
    USER_ALL_LMPASSWORDPRESENT | \
    USER_ALL_PASSWORDEXPIRED | \
    USER_ALL_SECURITYDESCRIPTOR | \
    USER_ALL_PRIVATEDATA)

// Fields that can't be read.

#define USER_ALL_READ_CANT_MASK USER_ALL_UNDEFINED_MASK

// Fields that require USER_WRITE_ACCOUNT access to write.

#define USER_ALL_WRITE_ACCOUNT_MASK \
    (USER_ALL_USERNAME | \
    USER_ALL_FULLNAME | \
    USER_ALL_PRIMARYGROUPID | \
    USER_ALL_HOMEDIRECTORY | \
    USER_ALL_HOMEDIRECTORYDRIVE | \
    USER_ALL_SCRIPTPATH | \
    USER_ALL_PROFILEPATH | \
    USER_ALL_ADMINCOMMENT | \
    USER_ALL_WORKSTATIONS | \
    USER_ALL_LOGONHOURS | \
    USER_ALL_ACCOUNTEXPIRES | \
    USER_ALL_USERACCOUNTCONTROL | \
    USER_ALL_PARAMETERS)

// Fields that require USER_WRITE_PREFERENCES access to write.

#define USER_ALL_WRITE_PREFERENCES_MASK \
    (USER_ALL_USERCOMMENT | USER_ALL_COUNTRYCODE | USER_ALL_CODEPAGE)

// Fields that require USER_FORCE_PASSWORD_CHANGE access to write.
//
// Note that non-trusted clients only set the NT password as a
// UNICODE string. The wrapper will convert it to an LM password,
// OWF and encrypt both versions. Trusted clients can pass in OWF
// versions of either or both.

#define USER_ALL_WRITE_FORCE_PASSWORD_CHANGE_MASK \
    (USER_ALL_NTPASSWORDPRESENT | \
    USER_ALL_LMPASSWORDPRESENT | \
    USER_ALL_PASSWORDEXPIRED)

// Fields that can only be written by trusted clients.

#define USER_ALL_WRITE_TRUSTED_MASK \
    (USER_ALL_LASTLOGON | \
    USER_ALL_LASTLOGOFF | \
    USER_ALL_BADPASSWORDCOUNT | \
    USER_ALL_LOGONCOUNT | \
    USER_ALL_PASSWORDLASTSET | \
    USER_ALL_SECURITYDESCRIPTOR | \
    USER_ALL_PRIVATEDATA)

// Fields that can't be written.

#define USER_ALL_WRITE_CANT_MASK \
    (USER_ALL_USERID | \
    USER_ALL_PASSWORDCANCHANGE | \
    USER_ALL_PASSWORDMUSTCHANGE | \
    USER_ALL_UNDEFINED_MASK)

#include <pshpack4.h>
typedef struct _USER_ALL_INFORMATION
{
    LARGE_INTEGER LastLogon;
    LARGE_INTEGER LastLogoff;
    LARGE_INTEGER PasswordLastSet;
    LARGE_INTEGER AccountExpires;
    LARGE_INTEGER PasswordCanChange;
    LARGE_INTEGER PasswordMustChange;
    UNICODE_STRING UserName;
    UNICODE_STRING FullName;
    UNICODE_STRING HomeDirectory;
    UNICODE_STRING HomeDirectoryDrive;
    UNICODE_STRING ScriptPath;
    UNICODE_STRING ProfilePath;
    UNICODE_STRING AdminComment;
    UNICODE_STRING WorkStations;
    UNICODE_STRING UserComment;
    UNICODE_STRING Parameters;
    UNICODE_STRING LmPassword;
    UNICODE_STRING NtPassword;
    UNICODE_STRING PrivateData;
    SR_SECURITY_DESCRIPTOR SecurityDescriptor;
    ULONG UserId;
    ULONG PrimaryGroupId;
    ULONG UserAccountControl;
    ULONG WhichFields;
    LOGON_HOURS LogonHours;
    USHORT BadPasswordCount;
    USHORT LogonCount;
    USHORT CountryCode;
    USHORT CodePage;
    BOOLEAN LmPasswordPresent;
    BOOLEAN NtPasswordPresent;
    BOOLEAN PasswordExpired;
    BOOLEAN PrivateDataSensitive;
} USER_ALL_INFORMATION, *PUSER_ALL_INFORMATION;
#include <poppack.h>

typedef SAM_BYTE_ARRAY_32K SAM_USER_TILE, *PSAM_USER_TILE;

// 0xff000fff is reserved for internal callers and implementation.

#define USER_EXTENDED_FIELD_USER_TILE (0x00001000L)
#define USER_EXTENDED_FIELD_PASSWORD_HINT (0x00002000L)
#define USER_EXTENDED_FIELD_DONT_SHOW_IN_LOGON_UI (0x00004000L)
#define USER_EXTENDED_FIELD_SHELL_ADMIN_OBJECT_PROPERTIES (0x00008000L)

typedef struct _USER_EXTENDED_INFORMATION
{
    ULONG ExtendedWhichFields;
    SAM_USER_TILE UserTile;
    UNICODE_STRING PasswordHint;
    BOOLEAN DontShowInLogonUI;
    SAM_SHELL_OBJECT_PROPERTIES ShellAdminObjectProperties;
} USER_EXTENDED_INFORMATION, *PUSER_EXTENDED_INFORMATION;

// For local callers only.
typedef struct _USER_LOGON_UI_INFORMATION
{
    BOOLEAN PasswordIsBlank;
    BOOLEAN AccountIsDisabled;
} USER_LOGON_UI_INFORMATION, *PUSER_LOGON_UI_INFORMATION;

// SamChangePasswordUser3 types

// Error values:
// * SAM_PWD_CHANGE_NO_ERROR
// * SAM_PWD_CHANGE_PASSWORD_TOO_SHORT
// * SAM_PWD_CHANGE_PWD_IN_HISTORY
// * SAM_PWD_CHANGE_USERNAME_IN_PASSWORD
// * SAM_PWD_CHANGE_FULLNAME_IN_PASSWORD
// * SAM_PWD_CHANGE_MACHINE_PASSWORD_NOT_DEFAULT
// * SAM_PWD_CHANGE_FAILED_BY_FILTER

typedef struct _USER_PWD_CHANGE_FAILURE_INFORMATION
{
    ULONG ExtendedFailureReason;
    UNICODE_STRING FilterModuleName;
} USER_PWD_CHANGE_FAILURE_INFORMATION,*PUSER_PWD_CHANGE_FAILURE_INFORMATION;

// ExtendedFailureReason values

#define SAM_PWD_CHANGE_NO_ERROR 0
#define SAM_PWD_CHANGE_PASSWORD_TOO_SHORT 1
#define SAM_PWD_CHANGE_PWD_IN_HISTORY 2
#define SAM_PWD_CHANGE_USERNAME_IN_PASSWORD 3
#define SAM_PWD_CHANGE_FULLNAME_IN_PASSWORD 4
#define SAM_PWD_CHANGE_NOT_COMPLEX 5
#define SAM_PWD_CHANGE_MACHINE_PASSWORD_NOT_DEFAULT 6
#define SAM_PWD_CHANGE_FAILED_BY_FILTER 7
#define SAM_PWD_CHANGE_PASSWORD_TOO_LONG 8
#define SAM_PWD_CHANGE_FAILURE_REASON_MAX 8

// Functions

_Check_return_
NTSTATUS
NTAPI
SamEnumerateUsersInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _Inout_ PSAM_ENUMERATE_HANDLE EnumerationContext,
    _In_ ULONG UserAccountControl,
    _Outptr_ PVOID *Buffer, // PSAM_RID_ENUMERATION *
    _In_ ULONG PreferedMaximumLength,
    _Out_ PULONG CountReturned
    );

_Check_return_
NTSTATUS
NTAPI
SamCreateUserInDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ PUNICODE_STRING AccountName,
    _In_ ACCESS_MASK DesiredAccess,
    _Out_ PSAM_HANDLE UserHandle,
    _Out_ PULONG RelativeId
    );

_Check_return_
NTSTATUS
NTAPI
SamCreateUser2InDomain(
    _In_ SAM_HANDLE DomainHandle,
    _In_ PUNICODE_STRING AccountName,
    _In_ ULONG AccountType,
    _In_ ACCESS_MASK DesiredAccess,
    _Out_ PSAM_HANDLE UserHandle,
    _Out_ PULONG GrantedAccess,
    _Out_ PULONG RelativeId
    );

_Check_return_
NTSTATUS
NTAPI
SamOpenUser(
    _In_ SAM_HANDLE DomainHandle,
    _In_ ACCESS_MASK DesiredAccess,
    _In_ ULONG UserId,
    _Out_ PSAM_HANDLE UserHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamDeleteUser(
    _In_ SAM_HANDLE UserHandle
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryInformationUser(
    _In_ SAM_HANDLE UserHandle,
    _In_ USER_INFORMATION_CLASS UserInformationClass,
    _Outptr_ PVOID *Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamSetInformationUser(
    _In_ SAM_HANDLE UserHandle,
    _In_ USER_INFORMATION_CLASS UserInformationClass,
    _In_ PVOID Buffer
    );

_Check_return_
NTSTATUS
NTAPI
SamGetGroupsForUser(
    _In_ SAM_HANDLE UserHandle,
    _Out_ _Deref_post_count_(*MembershipCount) PGROUP_MEMBERSHIP *Groups,
    _Out_ PULONG MembershipCount
    );

_Check_return_
NTSTATUS
NTAPI
SamChangePasswordUser(
    _In_ SAM_HANDLE UserHandle,
    _In_ PUNICODE_STRING OldPassword,
    _In_ PUNICODE_STRING NewPassword
    );

_Check_return_
NTSTATUS
NTAPI
SamChangePasswordUser2(
    _In_ PUNICODE_STRING ServerName,
    _In_ PUNICODE_STRING UserName,
    _In_ PUNICODE_STRING OldPassword,
    _In_ PUNICODE_STRING NewPassword
    );

_Check_return_
NTSTATUS
NTAPI
SamChangePasswordUser3(
    _In_ PUNICODE_STRING ServerName,
    _In_ PUNICODE_STRING UserName,
    _In_ PUNICODE_STRING OldPassword,
    _In_ PUNICODE_STRING NewPassword,
    _Outptr_ PDOMAIN_PASSWORD_INFORMATION *EffectivePasswordPolicy,
    _Outptr_ PUSER_PWD_CHANGE_FAILURE_INFORMATION *PasswordChangeFailureInfo
    );

_Check_return_
NTSTATUS
NTAPI
SamQueryDisplayInformation(
    _In_ SAM_HANDLE DomainHandle,
    _In_ DOMAIN_DISPLAY_INFORMATION DisplayInformation,
    _In_ ULONG Index,
    _In_ ULONG EntryCount,
    _In_ ULONG PreferredMaximumLength,
    _In_ PULONG TotalAvailable,
    _Out_ PULONG TotalReturned,
    _Out_ PULONG ReturnedEntryCount,
    _Outptr_ PVOID *SortedBuffer
    );

_Check_return_
NTSTATUS
NTAPI
SamGetDisplayEnumerationIndex(
    _In_ SAM_HANDLE DomainHandle,
    _In_ DOMAIN_DISPLAY_INFORMATION DisplayInformation,
    _In_ PUNICODE_STRING Prefix,
    _Out_ PULONG Index
    );

// Database replication

typedef enum _SECURITY_DB_DELTA_TYPE
{
    SecurityDbNew = 1,
    SecurityDbRename,
    SecurityDbDelete,
    SecurityDbChangeMemberAdd,
    SecurityDbChangeMemberSet,
    SecurityDbChangeMemberDel,
    SecurityDbChange,
    SecurityDbChangePassword
} SECURITY_DB_DELTA_TYPE, *PSECURITY_DB_DELTA_TYPE;

typedef enum _SECURITY_DB_OBJECT_TYPE
{
    SecurityDbObjectSamDomain = 1,
    SecurityDbObjectSamUser,
    SecurityDbObjectSamGroup,
    SecurityDbObjectSamAlias,
    SecurityDbObjectLsaPolicy,
    SecurityDbObjectLsaTDomain,
    SecurityDbObjectLsaAccount,
    SecurityDbObjectLsaSecret
} SECURITY_DB_OBJECT_TYPE, *PSECURITY_DB_OBJECT_TYPE;

typedef enum _SAM_ACCOUNT_TYPE
{
    SamObjectUser = 1,
    SamObjectGroup,
    SamObjectAlias
} SAM_ACCOUNT_TYPE, *PSAM_ACCOUNT_TYPE;

#define SAM_USER_ACCOUNT (0x00000001)
#define SAM_GLOBAL_GROUP_ACCOUNT (0x00000002)
#define SAM_LOCAL_GROUP_ACCOUNT (0x00000004)

typedef struct _SAM_GROUP_MEMBER_ID
{
    ULONG MemberRid;
} SAM_GROUP_MEMBER_ID, *PSAM_GROUP_MEMBER_ID;

typedef struct _SAM_ALIAS_MEMBER_ID
{
    PSID MemberSid;
} SAM_ALIAS_MEMBER_ID, *PSAM_ALIAS_MEMBER_ID;

typedef union _SAM_DELTA_DATA
{
    SAM_GROUP_MEMBER_ID GroupMemberId;
    SAM_ALIAS_MEMBER_ID AliasMemberId;
    ULONG AccountControl;
} SAM_DELTA_DATA, *PSAM_DELTA_DATA;

typedef NTSTATUS (NTAPI *PSAM_DELTA_NOTIFICATION_ROUTINE)(
    _In_ PSID DomainSid,
    _In_ SECURITY_DB_DELTA_TYPE DeltaType,
    _In_ SECURITY_DB_OBJECT_TYPE ObjectType,
    _In_ ULONG ObjectRid,
    _In_opt_ PUNICODE_STRING ObjectName,
    _In_ PLARGE_INTEGER ModifiedCount,
    _In_opt_ PSAM_DELTA_DATA DeltaData
    );

#define SAM_DELTA_NOTIFY_ROUTINE "DeltaNotify"

_Check_return_
NTSTATUS
NTAPI
SamRegisterObjectChangeNotification(
    _In_ SECURITY_DB_OBJECT_TYPE ObjectType,
    _In_ HANDLE NotificationEventHandle
    );

NTSTATUS
NTAPI
SamUnregisterObjectChangeNotification(
    _In_ SECURITY_DB_OBJECT_TYPE ObjectType,
    _In_ HANDLE NotificationEventHandle
    );

// Compatibility mode

#define SAM_SID_COMPATIBILITY_ALL 0
#define SAM_SID_COMPATIBILITY_LAX 1
#define SAM_SID_COMPATIBILITY_STRICT 2

_Check_return_
NTSTATUS
NTAPI
SamGetCompatibilityMode(
    _In_ SAM_HANDLE ObjectHandle,
    _Out_ ULONG *Mode
    );

// Password validation

typedef enum _PASSWORD_POLICY_VALIDATION_TYPE
{
    SamValidateAuthentication = 1,
    SamValidatePasswordChange,
    SamValidatePasswordReset
} PASSWORD_POLICY_VALIDATION_TYPE;

typedef struct _SAM_VALIDATE_PASSWORD_HASH
{
    ULONG Length;
    _Field_size_bytes_(Length) PUCHAR Hash;
} SAM_VALIDATE_PASSWORD_HASH, *PSAM_VALIDATE_PASSWORD_HASH;

// Flags for PresentFields in SAM_VALIDATE_PERSISTED_FIELDS

#define SAM_VALIDATE_PASSWORD_LAST_SET 0x00000001
#define SAM_VALIDATE_BAD_PASSWORD_TIME 0x00000002
#define SAM_VALIDATE_LOCKOUT_TIME 0x00000004
#define SAM_VALIDATE_BAD_PASSWORD_COUNT 0x00000008
#define SAM_VALIDATE_PASSWORD_HISTORY_LENGTH 0x00000010
#define SAM_VALIDATE_PASSWORD_HISTORY 0x00000020

typedef struct _SAM_VALIDATE_PERSISTED_FIELDS
{
    ULONG PresentFields;
    LARGE_INTEGER PasswordLastSet;
    LARGE_INTEGER BadPasswordTime;
    LARGE_INTEGER LockoutTime;
    ULONG BadPasswordCount;
    ULONG PasswordHistoryLength;
    _Field_size_bytes_(PasswordHistoryLength) PSAM_VALIDATE_PASSWORD_HASH PasswordHistory;
} SAM_VALIDATE_PERSISTED_FIELDS, *PSAM_VALIDATE_PERSISTED_FIELDS;

typedef enum _SAM_VALIDATE_VALIDATION_STATUS
{
    SamValidateSuccess = 0,
    SamValidatePasswordMustChange,
    SamValidateAccountLockedOut,
    SamValidatePasswordExpired,
    SamValidatePasswordIncorrect,
    SamValidatePasswordIsInHistory,
    SamValidatePasswordTooShort,
    SamValidatePasswordTooLong,
    SamValidatePasswordNotComplexEnough,
    SamValidatePasswordTooRecent,
    SamValidatePasswordFilterError
} SAM_VALIDATE_VALIDATION_STATUS, *PSAM_VALIDATE_VALIDATION_STATUS;

typedef struct _SAM_VALIDATE_STANDARD_OUTPUT_ARG
{
    SAM_VALIDATE_PERSISTED_FIELDS ChangedPersistedFields;
    SAM_VALIDATE_VALIDATION_STATUS ValidationStatus;
} SAM_VALIDATE_STANDARD_OUTPUT_ARG, *PSAM_VALIDATE_STANDARD_OUTPUT_ARG;

typedef struct _SAM_VALIDATE_AUTHENTICATION_INPUT_ARG
{
    SAM_VALIDATE_PERSISTED_FIELDS InputPersistedFields;
    BOOLEAN PasswordMatched;
} SAM_VALIDATE_AUTHENTICATION_INPUT_ARG, *PSAM_VALIDATE_AUTHENTICATION_INPUT_ARG;

typedef struct _SAM_VALIDATE_PASSWORD_CHANGE_INPUT_ARG
{
    SAM_VALIDATE_PERSISTED_FIELDS InputPersistedFields;
    UNICODE_STRING ClearPassword;
    UNICODE_STRING UserAccountName;
    SAM_VALIDATE_PASSWORD_HASH HashedPassword;
    BOOLEAN PasswordMatch; // denotes if the old password supplied by user matched or not
} SAM_VALIDATE_PASSWORD_CHANGE_INPUT_ARG, *PSAM_VALIDATE_PASSWORD_CHANGE_INPUT_ARG;

typedef struct _SAM_VALIDATE_PASSWORD_RESET_INPUT_ARG
{
    SAM_VALIDATE_PERSISTED_FIELDS InputPersistedFields;
    UNICODE_STRING ClearPassword;
    UNICODE_STRING UserAccountName;
    SAM_VALIDATE_PASSWORD_HASH HashedPassword;
    BOOLEAN PasswordMustChangeAtNextLogon; // looked at only for password reset
    BOOLEAN ClearLockout; // can be used clear user account lockout
}SAM_VALIDATE_PASSWORD_RESET_INPUT_ARG, *PSAM_VALIDATE_PASSWORD_RESET_INPUT_ARG;

typedef union _SAM_VALIDATE_INPUT_ARG
{
    SAM_VALIDATE_AUTHENTICATION_INPUT_ARG ValidateAuthenticationInput;
    SAM_VALIDATE_PASSWORD_CHANGE_INPUT_ARG ValidatePasswordChangeInput;
    SAM_VALIDATE_PASSWORD_RESET_INPUT_ARG ValidatePasswordResetInput;
} SAM_VALIDATE_INPUT_ARG, *PSAM_VALIDATE_INPUT_ARG;

typedef union _SAM_VALIDATE_OUTPUT_ARG
{
    SAM_VALIDATE_STANDARD_OUTPUT_ARG ValidateAuthenticationOutput;
    SAM_VALIDATE_STANDARD_OUTPUT_ARG ValidatePasswordChangeOutput;
    SAM_VALIDATE_STANDARD_OUTPUT_ARG ValidatePasswordResetOutput;
} SAM_VALIDATE_OUTPUT_ARG, *PSAM_VALIDATE_OUTPUT_ARG;

_Check_return_
NTSTATUS
NTAPI
SamValidatePassword(
    _In_opt_ PUNICODE_STRING ServerName,
    _In_ PASSWORD_POLICY_VALIDATION_TYPE ValidationType,
    _In_ PSAM_VALIDATE_INPUT_ARG InputArg,
    _Out_ PSAM_VALIDATE_OUTPUT_ARG *OutputArg
    );

// Generic operation

typedef enum _SAM_GENERIC_OPERATION_TYPE
{
    SamObjectChangeNotificationOperation
} SAM_GENERIC_OPERATION_TYPE, *PSAM_GENERIC_OPERATION_TYPE;

typedef struct _SAM_OPERATION_OBJCHG_INPUT
{
    BOOLEAN Register;
    ULONG64 EventHandle;
    SECURITY_DB_OBJECT_TYPE ObjectType;
    ULONG ProcessID;
} SAM_OPERATION_OBJCHG_INPUT, *PSAM_OPERATION_OBJCHG_INPUT;

typedef struct _SAM_OPERATION_OBJCHG_OUTPUT
{
    ULONG Reserved;
} SAM_OPERATION_OBJCHG_OUTPUT, *PSAM_OPERATION_OBJCHG_OUTPUT;

typedef union _SAM_GENERIC_OPERATION_INPUT
{
    SAM_OPERATION_OBJCHG_INPUT ObjChangeIn;
} SAM_GENERIC_OPERATION_INPUT, *PSAM_GENERIC_OPERATION_INPUT;

typedef union _SAM_GENERIC_OPERATION_OUTPUT
{
    SAM_OPERATION_OBJCHG_OUTPUT ObjChangeOut;
} SAM_GENERIC_OPERATION_OUTPUT, *PSAM_GENERIC_OPERATION_OUTPUT;

_Check_return_
NTSTATUS
NTAPI
SamPerformGenericOperation(
    _In_opt_ PWSTR ServerName,
    _In_ SAM_GENERIC_OPERATION_TYPE OperationType,
    _In_ PSAM_GENERIC_OPERATION_INPUT OperationIn,
    _Out_ PSAM_GENERIC_OPERATION_OUTPUT *OperationOut
    );

#endif
