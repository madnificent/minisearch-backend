(in-package :mu-cl-resources)

;;;;
;; NOTE
;; docker-compose stop; docker-compose rm; docker-compose up
;; after altering this file.

;; Describe your resources here

;; The general structure could be described like this:
;;
;; (define-resource <name-used-in-this-file> ()
;;   :class <class-of-resource-in-triplestore>
;;   :properties `((<json-property-name-one> <type-one> ,<triplestore-relation-one>)
;;                 (<json-property-name-two> <type-two> ,<triplestore-relation-two>>))
;;   :has-many `((<name-of-an-object> :via ,<triplestore-relation-to-objects>
;;                                    :as "<json-relation-property>")
;;               (<name-of-an-object> :via ,<triplestore-relation-from-objects>
;;                                    :inverse t ; follow relation in other direction
;;                                    :as "<json-relation-property>"))
;;   :has-one `((<name-of-an-object :via ,<triplestore-relation-to-object>
;;                                  :as "<json-relation-property>")
;;              (<name-of-an-object :via ,<triplestore-relation-from-object>
;;                                  :as "<json-relation-property>"))
;;   :resource-base (s-url "<string-to-which-uuid-will-be-appended-for-uri-of-new-items-in-triplestore>")
;;   :on-path "<url-path-on-which-this-resource-is-available>")


;; An example setup with a catalog, dataset, themes would be:
;;
;; (define-resource catalog ()
;;   :class (s-prefix "dcat:Catalog")
;;   :properties `((:title :string ,(s-prefix "dct:title")))
;;   :has-many `((dataset :via ,(s-prefix "dcat:dataset")
;;                        :as "datasets"))
;;   :resource-base (s-url "http://webcat.tmp.semte.ch/catalogs/")
;;   :on-path "catalogs")

;; (define-resource dataset ()
;;   :class (s-prefix "dcat:Dataset")
;;   :properties `((:title :string ,(s-prefix "dct:title"))
;;                 (:description :string ,(s-prefix "dct:description")))
;;   :has-one `((catalog :via ,(s-prefix "dcat:dataset")
;;                       :inverse t
;;                       :as "catalog"))
;;   :has-many `((theme :via ,(s-prefix "dcat:theme")
;;                      :as "themes"))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/datasets/")
;;   :on-path "datasets")

;; (define-resource distribution ()
;;   :class (s-prefix "dcat:Distribution")
;;   :properties `((:title :string ,(s-prefix "dct:title"))
;;                 (:access-url :url ,(s-prefix "dcat:accessURL")))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/distributions/")
;;   :on-path "distributions")

;; (define-resource theme ()
;;   :class (s-prefix "tfdcat:Theme")
;;   :properties `((:pref-label :string ,(s-prefix "skos:prefLabel")))
;;   :has-many `((dataset :via ,(s-prefix "dcat:theme")
;;                        :inverse t
;;                        :as "datasets"))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/themes/")
;;   :on-path "themes")

;;


(define-resource file ()
  :class (s-prefix "nfo:FileDataObject")
  :properties `((:filename :string ,(s-prefix "nfo:fileName"))
                (:format :string ,(s-prefix "dct:format"))
                (:size :number ,(s-prefix "nfo:fileSize"))
                (:extension :string ,(s-prefix "dbpedia:fileExtension"))
                (:created :datetime ,(s-prefix "nfo:fileCreated")))
  :has-one `((file :via ,(s-prefix "nie:dataSource")
                   :inverse t
                   :as "download"))
  :resource-base (s-url "http://data.example.com/files/")
  :features `(include-uri)
  :on-path "files")

(define-resource document ()
  :class (s-prefix "foaf:Document")
  :properties `((:archived        :boolean ,(s-prefix "besluitvorming:gearchiveerd"))
                (:title           :string ,(s-prefix "dct:title")) ;;string-set
                (:description     :string ,(s-prefix "ext:omschrijving")) ;;string-set
                (:confidential    :boolean ,(s-prefix "ext:vertrouwelijk")) ;;string-set
                (:created         :datetime ,(s-prefix "dct:created"))
                (:number-vp       :string ,(s-prefix "besluitvorming:stuknummerVP")) ;; NOTE: What is the URI of property 'stuknummerVP'? Made up besluitvorming:stuknummerVP
                (:number-vr       :string ,(s-prefix "besluitvorming:stuknummerVR"))) ;; NOTE: What is the URI of property 'stuknummerVR'? Made up besluitvorming:stuknummerVR
  :has-many `((document-version   :via ,(s-prefix "besluitvorming:heeftVersie")
                                  :as "document-versions"))
  :has-one `((document-type       :via ,(s-prefix "ext:documentType")
                                  :as "type")
             (file :via ,(s-prefix "ext:file")
                   :as "file"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/documenten/")
  :features '(include-uri)
  :on-path "documents")

(define-resource document-version ()
  :class (s-prefix "ext:DocumentVersie")
  :properties `((:version-number        :string   ,(s-prefix "ext:versieNummer"))
                (:created               :datetime ,(s-prefix "dct:created"))
                (:number-vr             :string ,(s-prefix "besluitvorming:stuknummerVR")) 
                (:chosen-file-name      :string   ,(s-prefix "ext:gekozenDocumentNaam")))
  :has-one `((file                      :via      ,(s-prefix "ext:file")
                                        :as "file")
            (document                   :via      ,(s-prefix "besluitvorming:heeftVersie")
                                        :inverse t
                                        :as "document"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/document-versies/")
  :features `(include-uri)
  :on-path "document-versions")

(define-resource document-type ()
  :class (s-prefix "ext:DocumentTypeCode")
  :properties `((:label             :string ,(s-prefix "skos:prefLabel"))
                (:scope-note        :string ,(s-prefix "skos:scopeNote"))
                (:alt-label         :string ,(s-prefix "skos:altLabel")))
  :has-many `((document             :via    ,(s-prefix "ext:documentType")
                                    :inverse t
                                    :as "documents")
              (document-type        :via    ,(s-prefix "skos:broader")
                                    :inverse t
                                    :as "subtypes"))
  :has-one `((document-type         :via    ,(s-prefix "skos:broader")
                                    :as "supertype"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/document-type-codes/")
  :features '(include-uri)
  :on-path "document-types")
