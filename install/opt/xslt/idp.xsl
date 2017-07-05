<?xml version="1.0"?>
<!--
  Copyright (C) 2013 Peter Schober <peter@aco.net>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
  Modifications by Rainer Hörbe, Stadt Wien, MA14.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui" 
                xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
                xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
                exclude-result-prefixes="md mdui mdrpi shibmd">
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="/md:EntitiesDescriptor">
    <html>
    <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/></head>
    <body>
    <table id="datatable" border="1" cellpadding="5" cellspacing="0">
    <thead>
      <tr class="eduid_head"><th>Organisation</th><th>Techn.<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>Kontakt</th><th>Attribut<xsl:text disable-output-escaping="yes">&amp;#8209;</xsl:text>"Scope"</th><th>SAML Entity</th></tr>
    </thead>
    <tbody>
    <xsl:apply-templates select="md:EntityDescriptor[md:IDPSSODescriptor]"/>
    </tbody>
    <tfoot>
      <tr class="eduid_head"><th>Organisation</th><th>Techn.<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>Kontakt</th><th>Attribut<xsl:text disable-output-escaping="yes">&amp;#8209;</xsl:text>"Scope"</th><th>SAML Entity</th></tr>
    </tfoot>
    </table>
    <br />
    </body>
    </html>
  </xsl:template>

  <xsl:template match="md:EntityDescriptor">
    <!-- Try hard to find a Name -->
    <xsl:variable name="mduiName.de"><xsl:value-of select="normalize-space(md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='de'])"/></xsl:variable>
    <xsl:variable name="mduiName.en"><xsl:value-of select="normalize-space(md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en'])"/></xsl:variable>
    <xsl:variable name="mduiName.any"><xsl:value-of select="normalize-space(md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang and @xml:lang!='de' and @xml:lang!='en'][1])"/></xsl:variable>
    <xsl:variable name="orgName.de"><xsl:value-of select="normalize-space(md:Organization/md:OrganizationDisplayName[@xml:lang='de'])"/></xsl:variable>
    <xsl:variable name="orgName.en"><xsl:value-of select="normalize-space(md:Organization/md:OrganizationDisplayName[@xml:lang='en'])"/></xsl:variable>
    <xsl:variable name="orgName.any"><xsl:value-of select="normalize-space(md:Organization/md:OrganizationDisplayName[@xml:lang and @xml:lang!='de' and @xml:lang!='en'][1])"/></xsl:variable>
    <xsl:variable name="Name">
      <xsl:choose>
        <xsl:when test="string-length($mduiName.de) > 0">
          <xsl:value-of select="$mduiName.de"/>
        </xsl:when>
        <xsl:when test="string-length($mduiName.en) > 0">
          <xsl:value-of select="$mduiName.en"/>
        </xsl:when>
        <xsl:when test="string-length($orgName.de) > 0">
          <xsl:value-of select="$orgName.de"/>
        </xsl:when>
        <xsl:when test="string-length($orgName.en) > 0">
          <xsl:value-of select="$orgName.en"/>
        </xsl:when>
        <xsl:when test="string-length($mduiName.any) > 0">
          <xsl:value-of select="$mduiName.any"/>
        </xsl:when>
        <xsl:when test="string-length($orgName.any) > 0">
          <xsl:value-of select="$orgName.any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Try hard to find an Info URL -->
    <xsl:variable name="mduiURL.de"><xsl:value-of select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang='de']"/></xsl:variable>
    <xsl:variable name="mduiURL.en"><xsl:value-of select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang='en']"/></xsl:variable>
    <xsl:variable name="mduiURL.any"><xsl:value-of select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang and @xml:lang!='de' and @xml:lang!='en'][1]"/></xsl:variable>
    <xsl:variable name="mduiURL">
      <xsl:choose>
        <xsl:when test="string-length($mduiURL.de) > 0">
          <xsl:value-of select="$mduiURL.de"/>
        </xsl:when>
        <xsl:when test="string-length($mduiURL.en) > 0">
          <xsl:value-of select="$mduiURL.en"/>
        </xsl:when>
        <xsl:when test="string-length($mduiURL.any) > 0">
          <xsl:value-of select="$mduiURL.any"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- Try hard to find an Org URL -->
    <xsl:variable name="orgURL.de"><xsl:value-of select="md:Organization/md:OrganizationURL[@xml:lang='de']"/></xsl:variable>
    <xsl:variable name="orgURL.en"><xsl:value-of select="md:Organization/md:OrganizationURL[@xml:lang='en']"/></xsl:variable>
    <xsl:variable name="orgURL.any"><xsl:value-of select="md:Organization/md:OrganizationURL[@xml:lang and @xml:lang!='de' and @xml:lang!='en'][1]"/></xsl:variable>
    <xsl:variable name="orgURL">
      <xsl:choose>
        <xsl:when test="string-length($orgURL.de) > 0">
          <xsl:value-of select="$orgURL.de"/>
        </xsl:when>
        <xsl:when test="string-length($orgURL.en) > 0">
          <xsl:value-of select="$orgURL.en"/>
        </xsl:when>
        <xsl:when test="string-length($orgURL.any) > 0">
          <xsl:value-of select="$orgURL.any"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="regAuth"><xsl:value-of select="md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority"/></xsl:variable>

    <tr>
    
    <!-- Name + URL -->
    <td valign="top">
    <xsl:choose>
      <xsl:when test="$mduiURL and contains($mduiURL, '://')">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="$mduiURL"/>
          </xsl:attribute>
          <xsl:value-of select="$Name"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$orgURL and contains($orgURL, '://')">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="$orgURL"/>
          </xsl:attribute>
          <xsl:value-of select="$Name"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$Name"/>
      </xsl:otherwise>
    </xsl:choose>
    </td>

    <!-- Technical ContactPerson -->
    <td valign="top">
    <xsl:choose>
      <xsl:when test="count(md:ContactPerson[@contactType='technical']) > 1">
      <ul>
        <xsl:call-template name="Contacts"/>
      </ul>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="a">
          <xsl:attribute name="href"><xsl:text>mailto:</xsl:text>
            <xsl:apply-templates select="md:ContactPerson[@contactType='technical'][1]/md:EmailAddress"/>
          </xsl:attribute>
          <xsl:apply-templates select="md:ContactPerson[@contactType='technical'][1]"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    </td>

    <!-- Scope -->
    <td valign="top">
      <xsl:choose>
        <xsl:when test="count(md:IDPSSODescriptor/md:Extensions/shibmd:Scope) > 1">
        <ul>
          <xsl:call-template name="Scopes"/>
        </ul>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="md:IDPSSODescriptor/md:Extensions/shibmd:Scope"/>
        </xsl:otherwise> 
      </xsl:choose>
    </td>

    <!-- Entity -->
    <td valign="top">
    <tt><xsl:value-of select="@entityID"/></tt>

    <!-- Home Federation -->
    <!--
 xslt<xsl:if test="string-length($regAuth) > 0">
      <bxslt<xsl:text>(Registered bxslt/xsl:text>
     xslt<xsl:choose>
     xslt<xsl:when test="contains($regAuth, '://')">
       xslt<xsl:element name="a">
         xslt<xsl:attribute name="hrexslt<xsl:value-of select="$regAuth"xslt/xsl:attribute>
         xslt<xsl:value-of select="$regAuth"/>
        xslt/xsl:element>
      xslt/xsl:when>
     xslt<xsl:otherwise>
       xslt<xsl:value-of select="$regAuth"/>
      xslt/xsl:otherwise>
    xslt/xsl:choose>
   xslt<xsl:textxslt/xsl:text>
  xslt/xsl:if>
    -->
    </td>

    </tr>
    <!xslt<xsl:text disable-output-escaping="yes">&lt;/tr&gxslt/xsl:text> -->
  </xsl:template>

  <xsl:template match="md:ContactPerson" name="ContactName">
    <xsl:apply-templates select="md:GivenName"/>
    <xsl:if test="md:GivenName">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="md:SurName"/>
  </xsl:template> 

  <xsl:template match="md:EmailAddress">
    <xsl:choose> 
      <xsl:when test="contains(text(),'mailto:')">
        <xsl:value-of select="normalize-space(substring-after(text(),'mailto:'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(text())"/>
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>

  <xsl:template match="md:GivenName">
    <xsl:value-of select="normalize-space(text())"/>
  </xsl:template>

  <xsl:template match="md:SurName">
    <xsl:value-of select="normalize-space(text())"/>
  </xsl:template>

  <xsl:template match="md:IDPSSODescriptor/md:Extensions/shibmd:Scope">
    <xsl:value-of select="normalize-space(text())"/>
  </xsl:template>

  <xsl:template name="Scopes">
    <xsl:for-each select="md:IDPSSODescriptor/md:Extensions/shibmd:Scope">
    <xsl:sort select="text()"/>
      <li>
        <xsl:value-of select="normalize-space(text())"/>
      </li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="Contacts">
    <xsl:for-each select="md:ContactPerson[@contactType='technical']">
    <li>
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:text>mailto:</xsl:text>
          <xsl:apply-templates select="md:EmailAddress"/>
        </xsl:attribute>
        <xsl:call-template name="ContactName"/>
      </xsl:element>
    </li>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
