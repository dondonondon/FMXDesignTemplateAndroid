unit BFA.Exception.Base;

interface

uses
  System.SysUtils;

type
  EBFAException = class(Exception);
  EBFAArgumentException = class(EBFAException);
  EBFAConfigurationException = class(EBFAException);
  EBFANotFoundException = class(EBFAException);
  EBFADuplicateException = class(EBFAException);

  EFrameRouterException = class(EBFAException);
  EFrameRouterArgumentException = class(EFrameRouterException);
  EFrameRouterAliasListEmptyException = class(EFrameRouterArgumentException);
  EFrameRouterAliasNotRegisteredException = class(EFrameRouterArgumentException);
  EFrameRouterAliasAlreadyRegisteredException = class(EFrameRouterException);
  EFrameRouterContainerNotAssignedException = class(EFrameRouterException);
  EFrameRouterFrameNotFoundException = class(EFrameRouterException);

  EKeyboardException = class(EBFAException);
  EKeyboardConfigurationException = class(EKeyboardException);
  EKeyboardFormNotAssignedException = class(EKeyboardConfigurationException);
  EKeyboardLayoutNotAssignedException = class(EKeyboardConfigurationException);
  EKeyboardVertScrollNotAssignedException = class(EKeyboardConfigurationException);

  EFormMessageException = class(EBFAException);
  EFormMessageConfigurationException = class(EFormMessageException);
  EFormMessageFormNotAssignedException = class(EFormMessageConfigurationException);

implementation

end.