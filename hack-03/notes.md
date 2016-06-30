__Simon__: "These properties map to broader / narrower." -- Input to the 
conversion process, to know which properties are hierarchical.  When you are
visualizing in generic visualizer -- view as a tree.  OBO "develops from" and 
"part of" -- for alot of ontologies, just a flat list.  If the broader part 
is transitive.  "For these object properties." -- we can specify.  Gazetteer is 
a good example.  To make sense, have to treat as hierarchical.  Need some way to 
input which ones.  By default, "related".  

__Marie__: OWL class should be SKOS Concept? [Yes].

__Simon__: For OBO library ontologies, they have a standard set of annotation 
properties that we could map to SKOS.  Synonyms and definition.  Then any 
transitive object property would map to SKOS broader.  But we know that part_of 
and develops_from map to SKOS broader - and they are the ones that are mostly.
170 ontologies in the OBO library would be covered.  Everything else maps by 
default to SKOS related.  Then question: superclass descriptions - whether you 
collect all the entitie and have them as related, which I think would be 
reasonable for SKOS representation.  

Good case for SKOS representation, because Bioportal - not possible to navigate 
via properties that are in anonymous class descriptions.

Simon Jupp
* http://mowl-power.cs.man.ac.uk:8080/obotoskos
* http://www.cs.man.ac.uk/~sjupp/skos/index.html - the mappings


* https://github.com/ontodev/robot
  Can convert between ontology formats.  The default format is RDF/XML, but 
  there are other RDF formats and the OBO file format.

    robot convert --input annotated.owl --output results/annotated.obo

1. Possibly, ROBOT could convert from OWL to SKOS - but this is just an 
   idea...
2. Convert OWL to OBO (Simon), then OBO to SKOS.
3. Maybe easier, SPARQL to convert from 

----------------------------------------------------------------------
OBO

    [Term]
    id: CL:0000097
    name: mast cell
    def: "A cell that is found in almost all tissues containing numerous basophilic granules and capable of releasing large amounts of histamine and
    heparin upon activation." [GOC:add, ISBN:068340007X, MESH:A.11.329.427]
    related_synonym: "tissue basophil" [ISBN:068340007X]
    exact_synonym: "labrocyte" [ISBN:0721601464]
    exact_synonym: "mastocyte" [ISBN:0721601464]
    is_a: CL:0000766 ! myeloid leukocyte
    relationship: develops_from CL:0000831 ! mast cell progenitor

to SKOS

    :CL_0000097
        :develops_from :CL_0000831 ;
        :is-a :CL_0000766 ;
        :super-class-of :CL_0000484, :CL_0000485 ;
        a skos:Concept ;
        skos:altLabel "\"labrocyte\" [ISBN:0721601464]"@en, "\"mastocyte\" [ISBN:0721601464]"@en, "\"tissue basophil\" [ISBN:068340007X]"@en ;
        skos:definition "\"A cell that is found in almost all tissues containing numerous basophilic granules and capable of releasing large amounts
    of histamine and heparin upon activation.\" [GOC:add, ISBN:068340007X, MESH:A.11.329.427]"@en ;
        skos:notation "CL:0000097"^^xsd:string ;
        skos:prefLabel "mast cell"@en .

----------------------------------------------------------------------

__Marie__: At the beginning, OBO didn't have reasoning, etc.   Was not convenient 
for community because they wanted to be able to work in Protege, use reasoners, etc.
But applications still needed the OBO format, so kept in parallel.

[Simon fixes the converter by updating to the latest Java, but Marie has
difficulty configuring Java 1.8.0_91, so we postpone use of Simon's converter 
until later and try to test some SPARQL queries.]

----------------------------------------------------------------------
Tom writes to Osma:

The Hackathon started yesterday evening, and there is interest in exploring
whether it could be useful to make a browsing interface for OWL ontologies
based on a back-end, lossy translation into SKOS.

Simon Jupp from Manchester is here.  He wrote about SKOS and OWL many years
ago, and uses SKOS this way in his work.  I gather he uses various heuristics
for turning some of the ontology relations into partOf.

The idea would be that, say, Plant Ontology could be translated into SKOS and
loaded into Skosmos or AgroPortal for simple browsing.

Interesting? Crazy?  Has anyone there discussed such a thing?

----------------------------------------------------------------------
Osma Suominen responds:

This is something we do quite routinely at NLF. YSO and its many domain
specific extensions are maintained as OWL ontologies (though nowadays most of
the properties are from SKOS) and translated to SKOS using Skosify as part of
the publishing process. Skosify can use a mapping file to convert e.g.
owl:Class into skos:Concept and rdfs:label into skos:prefLabel.

See https://github.com/NatLibFi/Skosify/wiki/OWL-conversion-to-SKOS
and the example configuration file
https://github.com/NatLibFi/Skosify/blob/master/owl2skos.cfg
which can be used to convert the DCMI Type vocabulary.

----------------------------------------------------------------------
Skosify - https://github.com/NatLibFi/Skosify

You can use Skosify to transform any vocabulary-like RDF/RDFS/OWL ontology into
SKOS format. You need to specify the way yor ontology structure maps to SKOS
constructs using a configuration file. See the provided configuration file
examples owl2skos.cfg and finnonto.cfg in the Skosify distribution package.

The specification is performed by editing the configuration file sections
[types], [literals] and [relations].

Based on the three mappings, Skosify will change your ontology structure. This
is a destructive operation: the old structure is replaced by the new
(presumably more SKOS-like) structure.

As an alternative, you can consider extending SKOS using RDFS subclass and
subproperty definitions and use the RDFSInference capabilities of Skosify. In
that approach, the original structure is kept intact. It may be more
appropriate to do so if your ontology already follows SKOS conventions, but
extends SKOS using RDFS.

----------------------------------------------------------------------

REQUIREMENTS
1. SKOS browser must show subproperties of skos:broader.  Example:

    agro:isPartOf 
        rdfs:subPropertyOf skos:broader .
   
should be displayed as a hierarchy

    skos:LivingOrganism
      agro:Plant
        agro:Animal
          agro:Leaf

...where leaf is "part of" (a subproperty of broader).

2. Example:

    agro:Cow
      agro:eats  agro:Plant .

If agro:eats is a subproperty of skos:related, this means that Cow is 
somehow related to Plant.  However, this should not be part of the 
display hierarchy.
