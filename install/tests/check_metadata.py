import lxml.etree

metadata = lxml.etree.parse('../testdata/md_feed/metadata.xml')
md_root = metadata.getroot()
XMLNS_MD = '{urn:oasis:names:tc:SAML:2.0:metadata}'
for e in md_root.findall(XMLNS_MD + 'EntityDescriptor'):
    print(e.attrib)
