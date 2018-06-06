<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <!-- Set protocolSupportEnumeration to containe only "urn:oasis:names:tc:SAML:2.0:protocol",
       if this value is already included.
       This will effectively remove any SAML:1.1 identifiers.
     r2h2 2018-06-05
  -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@protocolSupportEnumeration">
    <xsl:attribute name="protocolSupportEnumeration">
      <xsl:choose>
        <xsl:when test="contains(., 'urn:oasis:names:tc:SAML:2.0:protocol')">
          <xsl:text>urn:oasis:names:tc:SAML:2.0:protocol</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>