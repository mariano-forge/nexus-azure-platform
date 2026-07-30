{
  "name": "__ROOT_ID__",
  "management_groups": [
    {
      "archetypes": ["root", "root_override"],
      "display_name": "__ROOT_ID__ ALZ root",
      "exists": false,
      "id": "__ROOT_ID__",
      "parent_id": null
    },
    {
      "archetypes": ["landing_zones", "landing_zones_override"],
      "display_name": "__ROOT_ID__ Landing zones",
      "exists": false,
      "id": "__ROOT_ID__-landingzones",
      "parent_id": "__ROOT_ID__"
    },
    {
      "archetypes": ["corp", "corp_override"],
      "display_name": "__ROOT_ID__ Corp",
      "exists": false,
      "id": "__ROOT_ID__-corp",
      "parent_id": "__ROOT_ID__-landingzones"
    },
    {
      "archetypes": ["online", "online_override"],
      "display_name": "__ROOT_ID__ Online",
      "exists": false,
      "id": "__ROOT_ID__-online",
      "parent_id": "__ROOT_ID__-landingzones"
    },
    {
      "archetypes": ["local", "local_override"],
      "display_name": "__ROOT_ID__ Local",
      "exists": false,
      "id": "__ROOT_ID__-local",
      "parent_id": "__ROOT_ID__-landingzones"
    },
    {
      "archetypes": ["platform", "platform_override"],
      "display_name": "__ROOT_ID__ Platform",
      "exists": false,
      "id": "__ROOT_ID__-platform",
      "parent_id": "__ROOT_ID__"
    },
    {
      "archetypes": ["sandbox", "sandboxes_override"],
      "display_name": "__ROOT_ID__ Sandboxes",
      "exists": false,
      "id": "__ROOT_ID__-sandboxes",
      "parent_id": "__ROOT_ID__"
    },
    {
      "archetypes": ["management", "management_override"],
      "display_name": "__ROOT_ID__ Management",
      "exists": false,
      "id": "__ROOT_ID__-management",
      "parent_id": "__ROOT_ID__-platform"
    },
    {
      "archetypes": ["connectivity", "connectivity_override"],
      "display_name": "__ROOT_ID__ Connectivity",
      "exists": false,
      "id": "__ROOT_ID__-connectivity",
      "parent_id": "__ROOT_ID__-platform"
    },
    {
      "archetypes": ["security", "security_override"],
      "display_name": "__ROOT_ID__ Security",
      "exists": false,
      "id": "__ROOT_ID__-security",
      "parent_id": "__ROOT_ID__-platform"
    },
    {
      "archetypes": ["identity", "identity_override"],
      "display_name": "__ROOT_ID__ Identity",
      "exists": false,
      "id": "__ROOT_ID__-identity",
      "parent_id": "__ROOT_ID__-platform"
    },
    {
      "archetypes": ["decommissioned", "decommissioned_override"],
      "display_name": "__ROOT_ID__ Decommissioned",
      "exists": false,
      "id": "__ROOT_ID__-decommissioned",
      "parent_id": "__ROOT_ID__"
    }
  ]
}
