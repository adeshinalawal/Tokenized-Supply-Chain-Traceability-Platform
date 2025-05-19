;; Certification Contract
;; Validates compliance with standards

(define-map certifications
  { certification-id: (string-ascii 36) }
  {
    product-id: (string-ascii 36),
    certifier-id: (string-ascii 36),
    standard: (string-utf8 100),
    valid-until: uint,
    metadata-url: (optional (string-utf8 256)),
    timestamp: uint
  }
)

(define-read-only (get-certification (certification-id (string-ascii 36)))
  (map-get? certifications { certification-id: certification-id })
)

(define-read-only (get-product-certifications (product-id (string-ascii 36)))
  ;; In a real implementation, we would have a way to query all certifications for a product
  ;; For simplicity, this is not implemented here
  (ok true)
)

(define-public (issue-certification
    (certification-id (string-ascii 36))
    (product-id (string-ascii 36))
    (certifier-id (string-ascii 36))
    (standard (string-utf8 100))
    (valid-until uint)
    (metadata-url (optional (string-utf8 256)))
  )
  (let
    ((timestamp (get-block-info? time (- block-height u1))))
    (asserts! (is-some timestamp) (err u4000))
    (asserts! (is-none (get-certification certification-id)) (err u4001))

    ;; In production, verify that certifier is authorized

    (ok (map-set certifications
      { certification-id: certification-id }
      {
        product-id: product-id,
        certifier-id: certifier-id,
        standard: standard,
        valid-until: valid-until,
        metadata-url: metadata-url,
        timestamp: (unwrap-panic timestamp)
      }
    ))
  )
)

(define-public (revoke-certification (certification-id (string-ascii 36)))
  (begin
    ;; In production, verify that tx-sender is the certifier
    (match (map-get? certifications { certification-id: certification-id })
      certification (ok (map-set certifications
                        { certification-id: certification-id }
                        (merge certification { valid-until: u0 })
                      ))
      (err u4002)
    )
  )
)
