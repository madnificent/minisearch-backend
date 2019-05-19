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


(define-resource mailbox ()
  :class (s-prefix "nmo:Mailbox")
  :properties `((:id :string ,(s-prefix "nie:identifier")))
  :has-many `((folder :via ,(s-prefix "fni:hasPart")
                      :as "folders"))
  :resource-base (s-url "http://data.lblod.info/id/mailboxes/")
  :features '(include-uri)
  :on-path "mailboxes")

(define-resource folder ()
  :class (s-prefix "nfo:Folder")
  :properties `((:name :string ,(s-prefix "nie:title"))
                (:description :string ,(s-prefix "nie:description")))
  :has-many `((email :via ,(s-prefix "nmo:isPartOf");;hack, as mu-cl-resources doesn't support superclasses yet (http://oscaf.sourceforge.net/nmo.html#nmo:MailboxDataObject)
                     :inverse t
                     :as "emails")
              (folder :via ,(s-prefix "email:hasFolder");;hack, as mu-cl-resources doesn't support superclasses yet (http://oscaf.sourceforge.net/nmo.html#nmo:MailboxDataObject)
                      :as "folders"))
  :resource-base (s-url "http://data.lblod.info/id/mail-folders/")
  :features '(include-uri)
  :on-path "mail-folders")

(define-resource email ()
  :class (s-prefix "nmo:Email")
  :properties `((:message-id :string ,(s-prefix "nmo:messageId"));; e-mail protocol-specific id: https://tools.ietf.org/html/rfc2822#section-3.6.4
                (:from :string ,(s-prefix "nmo:messageFrom"))
                (:to :string ,(s-prefix "nmo:emailTo"))
                (:cc :string ,(s-prefix "nmo:emailCc"))
                (:bcc :string ,(s-prefix "nmo:emailBcc"))
                (:subject :string ,(s-prefix "nmo:messageSubject"))
                (:content :string ,(s-prefix "nmo:plainTextMessageContent"))
                (:html-content :string ,(s-prefix "nmo:htmlMessageContent"))
                (:is-read :boolean ,(s-prefix "nmo:isRead"))
                (:content-mime-type :string ,(s-prefix "nmo:contentMimeType"))
                (:received-date :datetime ,(s-prefix "nmo:receivedDate"))
                (:sent-date :datetime ,(s-prefix "nmo:sentDate")))
  :has-one `((email :via ,(s-prefix "nmo:inReplyTo")
                    :as "in-reply-to")
             (folder :via ,(s-prefix "nmo:isPartOf")
                     :as "folder"))
  :has-many `((email-header :via ,(s-prefix "nmo:messageHeader")
                            :as "headers")
              ;; (file :via ,(s-prefix "nmo:hasAttachment")
              ;;       :as "attachments")
              )
                                        ;           (email :via ,(s-prefix "nmo:references");;https://tools.ietf.org/html/rfc2822#section-3.6.4
                                        ;                   :as "references"))
  :resource-base (s-url "http://data.lblod.info/id/emails/")
  :features '(include-uri)
  :on-path "emails")

(define-resource email-header ()
  :class (s-prefix "nmo:MessageHeader")
  :properties `((:header-name :string ,(s-prefix "nmo:headerName"))
                (:header-value :string ,(s-prefix "nmo:headerValue")))
  :has-one `((email :via ,(s-prefix "nmo:messageHeader")
                    :inverse t
                    :as "email"))
  :resource-base (s-url "http://data.lblod.info/id/email-headers/")
  :features '(include-uri)
  :on-path "email-headers")


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
  :properties `((:title :string ,(s-prefix "dct:title"))
                (:description :string ,(s-prefix "ext:omschrijving")))
  :has-one `((file :via ,(s-prefix "ext:file")
                   :as "file"))
  :resource-base (s-url "http://data.example.com/documents/")
  :on-path "documents")
