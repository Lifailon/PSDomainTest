# PSDomainTest

PowerShell module to test DNS records of any domain using [ZoneMaster](https://github.com/zonemaster/zonemaster) api. 

By default, get down the result in the format of a PowerShell object whose metrics can be passed to a monitoring system (such as Zabbix or InfluxDB and Grafana 📊). The module also allows you to get the result in `json` format and `html` report.

💡 Testing some domains may take several minutes (for example, checking the `github.com` domain takes about 5 minutes on average). If a test request to the same domain is repeated within the next 10-15 minutes, the result of the previous (last) test will be returned.

## 🚀 Install

### Params:

| Name    | Description                                    | Type     | Mandatory |
| ---     | ---                                            | ---      | ---       |
| Domain  | Domain name                                    | `String` | **True**  |
| Warning | Output only warning and notice (excludes info) | `Switch` | **False** |
| json    | Output in json format                          | `Switch` | **False** |
| html    | Output in html report format                   | `Switch` | **False** |

### Examples:

- Output in **PowerShell object format** (default):

`Get-DomainTest -Domain github.com -Warning`

```PowerShell
Module       Test           Descriptions                                 Level   Result
------       ----           ------------                                 -----   ------
Connectivity Connectivity04 IP Prefix Diversity                          WARNING The following name server(s) are announced in th…
Connectivity Connectivity04 IP Prefix Diversity                          WARNING The following name server(s) are announced in th…
Connectivity Connectivity04 IP Prefix Diversity                          WARNING The following name server(s) are announced in th…
Connectivity Connectivity04 IP Prefix Diversity                          WARNING The following name server(s) are announced in th…
Consistency  Consistency01  SOA serial number consistency                WARNING Found 2 SOA serial number(s).…
Consistency  Consistency01  SOA serial number consistency                NOTICE  Difference between the smaller serial (1) and th…
Consistency  Consistency02  SOA RNAME consistency                        NOTICE  Found 2 SOA rname(s).…
Consistency  Consistency03  SOA timers consistency                       NOTICE  Found 2 SOA time parameter set(s).…
Consistency  Consistency06  SOA MNAME consistency                        NOTICE  Saw 2 SOA mname.…
DNSSEC       DNSSEC07       If DNSKEY at child, parent should have DS    NOTICE  There are neither DS nor DNSKEY records for the …
DNSSEC       Unspecified    Unspecified                                  NOTICE  The zone is not signed with DNSSEC.…
Nameserver   Nameserver15   Checking for revealed software version       NOTICE  The following name server(s) respond to software…
Nameserver   Nameserver15   Checking for revealed software version       NOTICE  The following name server(s) respond to software…
Nameserver   Nameserver15   Checking for revealed software version       NOTICE  The following name server(s) do not respond or r…
Nameserver   Nameserver15   Checking for revealed software version       NOTICE  The following name server(s) do not respond or r…
Syntax       Syntax06       No illegal characters in the SOA RNAME field NOTICE  The SOA RNAME mail domain (ns1-com.mail.protecti…
Zone         Zone01         Fully qualified master nameserver in SOA     WARNING SOA MNAME name server(s) "ns-1707.awsdns-21.co.u…
```

- Output in **json format**:

`Get-DomainTest -Domain github.com -Warning -json`

```json
[{"Domain": "github.com"},{"Date": "15.05.2024 8:46:59"},{"Url": "https://zonemaster.net/en/result/310632c6f444a5fb"},[
  {
    "Module": "Connectivity",
    "Test": "Connectivity04",
    "Descriptions": "IP Prefix Diversity",
    "Level": "WARNING",
    "Result": "The following name server(s) are announced in the same IPv4 prefix (198.51.45.0/24): \"dns2.p08.nsone.net/198.51.45.8; dns4.p08.nsone.net/198.51.45.72\"\n"
  },
  {
    "Module": "Connectivity",
    "Test": "Connectivity04",
    "Descriptions": "IP Prefix Diversity",
    "Level": "WARNING",
    "Result": "The following name server(s) are announced in the same IPv4 prefix (198.51.44.0/24): \"dns1.p08.nsone.net/198.51.44.8; dns3.p08.nsone.net/198.51.44.72\"\n"
  },
  {
    "Module": "Connectivity",
    "Test": "Connectivity04",
    "Descriptions": "IP Prefix Diversity",
    "Level": "WARNING",
    "Result": "The following name server(s) are announced in the same IPv6 prefix (2620:4d:4000::/48): \"dns1.p08.nsone.net/2620:4d:4000:6259:7:8:0:1; dns3.p08.nsone.net/2620:4d:4000:6259:7:8:0:3\"\n"
  },
  {
    "Module": "Connectivity",
    "Test": "Connectivity04",
    "Descriptions": "IP Prefix Diversity",
    "Level": "WARNING",
    "Result": "The following name server(s) are announced in the same IPv6 prefix (2a00:edc0:6259::/48): \"dns2.p08.nsone.net/2a00:edc0:6259:7:8::2; dns4.p08.nsone.net/2a00:edc0:6259:7:8::4\"\n"
  },
  {
    "Module": "Consistency",
    "Test": "Consistency01",
    "Descriptions": "SOA serial number consistency",
    "Level": "WARNING",
    "Result": "Found 2 SOA serial number(s).\n"
  },
  {
    "Module": "Consistency",
    "Test": "Consistency01",
    "Descriptions": "SOA serial number consistency",
    "Level": "NOTICE",
    "Result": "Difference between the smaller serial (1) and the bigger one (1656468023) is greater than the maximum allowed (0).\n"
  },
  {
    "Module": "Consistency",
    "Test": "Consistency02",
    "Descriptions": "SOA RNAME consistency",
    "Level": "NOTICE",
    "Result": "Found 2 SOA rname(s).\n"
  },
  {
    "Module": "Consistency",
    "Test": "Consistency03",
    "Descriptions": "SOA timers consistency",
    "Level": "NOTICE",
    "Result": "Found 2 SOA time parameter set(s).\n"
  },
  {
    "Module": "Consistency",
    "Test": "Consistency06",
    "Descriptions": "SOA MNAME consistency",
    "Level": "NOTICE",
    "Result": "Saw 2 SOA mname.\n"
  },
  {
    "Module": "DNSSEC",
    "Test": "DNSSEC07",
    "Descriptions": "If DNSKEY at child, parent should have DS",
    "Level": "NOTICE",
    "Result": "There are neither DS nor DNSKEY records for the zone.\n"
  },
  {
    "Module": "DNSSEC",
    "Test": "Unspecified",
    "Descriptions": "Unspecified",
    "Level": "NOTICE",
    "Result": "The zone is not signed with DNSSEC.\n"
  },
  {
    "Module": "Nameserver",
    "Test": "Nameserver15",
    "Descriptions": "Checking for revealed software version",
    "Level": "NOTICE",
    "Result": "The following name server(s) respond to software version query \"version.bind\" with string \"a0bd971e3\". Returned from name servers: \"dns1.p08.nsone.net/198.51.44.8; dns1.p08.nsone.net/2620:4d:4000:6259:7:8:0:1; dns2.p08.nsone.net/198.51.45.8; dns2.p08.nsone.net/2a00:edc0:6259:7:8::2; dns3.p08.nsone.net/198.51.44.72; dns3.p08.nsone.net/2620:4d:4000:6259:7:8:0:3; dns4.p08.nsone.net/198.51.45.72; dns4.p08.nsone.net/2a00:edc0:6259:7:8::4\"\n"
  },
  {
    "Module": "Nameserver",
    "Test": "Nameserver15",
    "Descriptions": "Checking for revealed software version",
    "Level": "NOTICE",
    "Result": "The following name server(s) respond to software version query \"version.server\" with string \"a0bd971e3\". Returned from name servers: \"dns1.p08.nsone.net/198.51.44.8; dns1.p08.nsone.net/2620:4d:4000:6259:7:8:0:1; dns2.p08.nsone.net/198.51.45.8; dns2.p08.nsone.net/2a00:edc0:6259:7:8::2; dns3.p08.nsone.net/198.51.44.72; dns3.p08.nsone.net/2620:4d:4000:6259:7:8:0:3; dns4.p08.nsone.net/198.51.45.72; dns4.p08.nsone.net/2a00:edc0:6259:7:8::4\"\n"
  },
  {
    "Module": "Nameserver",
    "Test": "Nameserver15",
    "Descriptions": "Checking for revealed software version",
    "Level": "NOTICE",
    "Result": "The following name server(s) do not respond or respond with SERVFAIL to software version query \"version.server\". Returned from name servers: \"ns-1283.awsdns-32.org/205.251.197.3; ns-1283.awsdns-32.org/2600:9000:5305:300::1; ns-1707.awsdns-21.co.uk/205.251.198.171; ns-1707.awsdns-21.co.uk/2600:9000:5306:ab00::1; ns-421.awsdns-52.com/205.251.193.165; ns-421.awsdns-52.com/2600:9000:5301:a500::1; ns-520.awsdns-01.net/205.251.194.8; ns-520.awsdns-01.net/2600:9000:5302:800::1\"\n"
  },
  {
    "Module": "Nameserver",
    "Test": "Nameserver15",
    "Descriptions": "Checking for revealed software version",
    "Level": "NOTICE",
    "Result": "The following name server(s) do not respond or respond with SERVFAIL to software version query \"version.bind\". Returned from name servers: \"ns-1283.awsdns-32.org/205.251.197.3; ns-1283.awsdns-32.org/2600:9000:5305:300::1; ns-1707.awsdns-21.co.uk/205.251.198.171; ns-1707.awsdns-21.co.uk/2600:9000:5306:ab00::1; ns-421.awsdns-52.com/205.251.193.165; ns-421.awsdns-52.com/2600:9000:5301:a500::1; ns-520.awsdns-01.net/205.251.194.8; ns-520.awsdns-01.net/2600:9000:5302:800::1\"\n"
  },
  {
    "Module": "Syntax",
    "Test": "Syntax06",
    "Descriptions": "No illegal characters in the SOA RNAME field",
    "Level": "NOTICE",
    "Result": "The SOA RNAME mail domain (ns1-com.mail.protection.outlook.com.) cannot be resolved to a mail server with an IP address.\n"
  },
  {
    "Module": "Zone",
    "Test": "Zone01",
    "Descriptions": "Fully qualified master nameserver in SOA",
    "Level": "WARNING",
    "Result": "SOA MNAME name server(s) \"ns-1707.awsdns-21.co.uk/205.251.198.171; ns-1707.awsdns-21.co.uk/2600:9000:5306:ab00::1\" do not have the highest SOA SERIAL (expected \"1\" but got \"1656468023; 1\")\n"
  }
]]
```

## 📢 Report

[Example HTML report](https://github.com/Lifailon/PSDomainTest/blob/rsa/test/github/result.html) for the domain `github.com` (the report provides the ability to sort by column).

```PowerShell
Get-DomainTest -Domain github.com -html | Out-File .\result.html
```

![Image alt](https://github.com/Lifailon/PSDomainTest/blob/rsa/image/html-report.jpg)