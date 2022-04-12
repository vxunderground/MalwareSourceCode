BOOL XmlLoad(PWSTR lpwcData, IXMLDOMDocument **pXMLDoc, IXMLDOMNode **pIDOMRootNode, PWSTR lpwcRootNodeName);
IXMLDOMNode * ConfGetListNodeByName(BSTR NodeName, IXMLDOMNodeList *pIDOMNodeList);
IXMLDOMNode * ConfGetNodeByName(BSTR NodeName, IXMLDOMNode *pIDOMNode);
BOOL ConfGetNodeTextW(IXMLDOMNode *pIDOMNode, PWSTR *str);
BOOL ConfGetNodeTextA(IXMLDOMNode *pIDOMNode, PCHAR *str);
BOOL ConfAllocGetTextByNameW(IXMLDOMNode *pIDOMNode, PWSTR name, PWSTR *value);
BOOL ConfAllocGetTextByNameA(IXMLDOMNode *pIDOMNode, PWSTR name, PCHAR *value);
BOOL ConfGetNodeAttributeW(IXMLDOMNode *pIDOMNode, PWSTR name, PWSTR *value);
BOOL ConfGetNodeAttributeA(IXMLDOMNode *pIDOMNode, PWSTR name, PCHAR *value);
