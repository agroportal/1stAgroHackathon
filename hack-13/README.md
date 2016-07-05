# TODO

* Different name for each created file (not "alvis_result.txt" for all)
* Generate Alvis dict when new terms added to NCBO dict
* Change STDIN when calling alvisnlp cmd

# Hack 13 - changing recognizer

Using alvis NLP

Main change will be done in https://github.com/agroportal/ncbo_annotator/tree/hack13

## Install Alvis

In the VM installed at `/srv/alvisnlp`

```
tar xvf alvisnlp.tar.gz
ant jarfiles

# Edit build.xml to put the hostname and build.properties (you can find them in this repo)
  <!--hostinfo prefix="thehost" /-->
  <property name="hostname" value="lguest-83" />

# Missing deps (using ant 1.7 or 1.6 works)
yum install ant
yum install ant-nodeps
apt-get install ant-optional

# Add weka from alvisnlp/lib in lib of alvis and edit path to weka jar in build.properties
ant realclean jarfiles

# In alvis repo
mkdir bin
./install.sh .

# Executable now in 
bin/alvisnlp
```

* Add the alvis-annotator folder

The plan and dictionaries for BioPortal are described in alvis-annotator (in this git repo)

alvis-annotator/dictionary-lemma.txt and alvis-annotator/dictionary-lemma.trie have to be generated from the BioPortal dictionary



## Install Tree Tagger

Download version (old kernel for NCBO VM) http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/
Download http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/english-par-linux-3.2-utf8.bin.gz

untar tree-tagger-linux-3.2-old.tar.gz
Test it: `bin/tree-tagger english-par-linux-3.2-utf8.bin` and enter a phrase separating words with enter

Link Alvis to treetagger (see in alvis config files)

## Change the config.rb

See the config.rb sample file in the repo

Main change is adding the following to Annotator config:

```ruby
Annotator.config do |config|
    config.enable_recognizer_param = true
    # in alvis dir: bin/alvisnlp and alvis-annotator/alvis-annotator.plan"
    config.alvis_recognizer_path = "/srv/alvisnlp"
    # in treetagger dir: english-par-linux-3.2.bin and bin/tree-tagger
    config.tree_tagger_path = "/srv/treetagger"
end
```

## Changing UI

Just have to define the recognizer array in the annotator controller

```ruby
@recognizers = parse_json(REST_URI + "/annotator/recognizers")
# It can be filled with a simple array
@recognizers = ["mgrep","alvis"]
```

https://github.com/agroportal/agroportal_web_ui/blob/master/app/controllers/annotator_controller.rb#L19
