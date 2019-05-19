alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do
  def user_groups do
    # These elements are walked from top to bottom.  Each of them may
    # alter the quads to which the current query applies.  Quads are
    # represented in three sections: current_source_quads,
    # removed_source_quads, new_quads.  The quads may be calculated in
    # many ways.  The useage of a GroupSpec and GraphCleanup are
    # common.
    [ %GroupSpec{
        name: "public",
        access: %AlwaysAccessible{},
        useage: [:read],
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/documents/",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://xmlns.com/foaf/0.1/Document",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject"
                      ],
                    }
                  } ]
      },
      %GroupSpec{
        name: "read_documents",
        useage: [:read],
        access: %AccessByQuery{ # This is a hack, we assume access
                                # through mock-login-service at all
                                # times.  If you see a strange URL as
                                # argument for read_documents,
                                # something did not pass through the
                                # MU_AUTH_ALLOWED_GROUPS
          query: "SELECT * WHERE { ?s ?p ?o. } LIMIT 1",
          vars: ["s"]
        },
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/documents/",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://xmlns.com/foaf/0.1/Document",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject"
                      ],
                    }
                  } ] },
      %GroupSpec{
        name: "write_documents",
        useage: [:write, :read_for_write],
        access: %AccessByQuery{ # This is a hack, we assume access
                                # through mock-login-service at all
                                # times.  If you see a strange URL as
                                # argument for read_documents,
                                # something did not pass through the
                                # MU_AUTH_ALLOWED_GROUPS
          query: "SELECT * WHERE { ?s ?p ?o. } LIMIT 1",
          vars: ["s"]
        },
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/documents/",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://xmlns.com/foaf/0.1/Document",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject"
                      ],
                    } } ]
      },
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
