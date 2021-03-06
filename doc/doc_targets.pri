# Creates targets for building documentation
# (adapted from qt_docs.prf)
#
# Usage: Define variables (details below) and include this pri file afterwards.
#
# QDOC_ENV            - environment variables to set for the qdoc call (see example below)
# DOC_INDEX_PATHS     - list of paths where qdoc should search for index files of dependent
#                       modules (Qt index path is included by default)
# DOC_FILES           - list of qdocconf files
# DOC_OUTDIR_POSTFIX  - html is generated in $$OUT_PWD/<qdocconf_name>$$DOC_OUTDIR_POSTFIX
# DOC_HTML_INSTALLDIR - path were to install the directory of html files
# DOC_QCH_OUTDIR      - path where to generated the qch files
# DOC_QCH_INSTALLDIR  - path where to install the qch files
# DOC_TARGET_PREFIX   - prefix for generated target names
#
# Example for QDOC_ENV:
# ver.name = VERSION
# ver.value = 1.0.2
# foo.name = FOO
# foo.value = foo
# QDOC_ENV = ver foo

isEmpty(DOC_FILES): error("Set DOC_FILES before including doc_targets.pri")
isEmpty(DOC_HTML_INSTALLDIR): error("Set DOC_HTML_INSTALLDIR before including doc_targets.pri")
isEmpty(DOC_QCH_OUTDIR): error("Set DOC_QCH_OUTDIR before including doc_targets.pri")
isEmpty(DOC_QCH_INSTALLDIR): error("Set DOC_QCH_INSTALLDIR before including doc_targets.pri")

QT_TOOL_ENV = $$QDOC_ENV
qtPrepareTool(QDOC, qdoc)
QT_TOOL_ENV =

!build_online_docs: qtPrepareTool(QHELPGENERATOR, qhelpgenerator)

DOCS_BASE_OUTDIR = $$OUT_PWD/doc
DOC_INDEXES += -indexdir $$shell_quote($$[QT_INSTALL_DOCS])
for (index_path, DOC_INDEX_PATHS): \
    DOC_INDEXES += -indexdir $$shell_quote($$index_path)

DTP = $$DOC_TARGET_PREFIX
for (doc_file, DOC_FILES) {
    !exists($$doc_file): error("Cannot find documentation specification file $$doc_file")
    DOC_TARGET = $$replace(doc_file, ^(.*/)?(.*)\\.qdocconf$, \\2)
    DOC_TARGETDIR = $$DOC_TARGET
    DOC_OUTPUTDIR = $${DOCS_BASE_OUTDIR}/$${DOC_TARGETDIR}$${DOC_OUTDIR_POSTFIX}

    $${DTP}html_docs_$${DOC_TARGET}.commands = $$QDOC -outputdir $$shell_quote($$DOC_OUTPUTDIR) $$doc_file $$DOC_INDEXES
    QMAKE_EXTRA_TARGETS += $${DTP}html_docs_$${DOC_TARGET}

    !isEmpty($${DTP}html_docs.commands): $${DTP}html_docs.commands += &&
    $${DTP}html_docs.commands += $$eval($${DTP}html_docs_$${DOC_TARGET}.commands)

    $${DTP}inst_html_docs.files += $$DOC_OUTPUTDIR

    !build_online_docs {
        $${DTP}qch_docs_$${DOC_TARGET}.commands = $$QHELPGENERATOR $$shell_quote($$DOC_OUTPUTDIR/$${DOC_TARGET}.qhp) -o $$shell_quote($$DOC_QCH_OUTDIR/$${DOC_TARGET}.qch)
        $${DTP}qch_docs_$${DOC_TARGET}.depends = $${DTP}html_docs_$${DOC_TARGET}
        QMAKE_EXTRA_TARGETS += $${DTP}qch_docs_$${DOC_TARGET}

        !isEmpty($${DTP}qch_docs.commands): $${DTP}qch_docs.commands += &&
        $${DTP}qch_docs.commands += $$eval($${DTP}qch_docs_$${DOC_TARGET}.commands)

        $${DTP}inst_qch_docs.files += $$DOC_QCH_OUTDIR/$${DOC_TARGET}.qch
    }
}

!build_online_docs {
    $${DTP}qch_docs.depends = $${DTP}html_docs
    $${DTP}inst_qch_docs.path = $$DOC_QCH_INSTALLDIR
    $${DTP}inst_qch_docs.CONFIG += no_check_exist no_default_install no_build
    install_$${DTP}docs.depends = install_$${DTP}inst_qch_docs
    $${DTP}docs.depends = $${DTP}qch_docs
    INSTALLS += $${DTP}inst_qch_docs
    QMAKE_EXTRA_TARGETS += $${DTP}qch_docs install_$${DTP}docs
} else {
    $${DTP}docs.depends = $${DTP}html_docs
}

$${DTP}inst_html_docs.path = $$DOC_HTML_INSTALLDIR
$${DTP}inst_html_docs.CONFIG += no_check_exist no_default_install directory
INSTALLS += $${DTP}inst_html_docs
install_$${DTP}docs.depends += install_$${DTP}inst_html_docs

QMAKE_EXTRA_TARGETS += $${DTP}html_docs $${DTP}docs

unset(DTP)
