extends Node

var X509_cert_filename = "x509_certificate.crt"
var X509_key_filename = "x509_key.key"
onready var X509_cert_path = "res://platinum-cert" + X509_cert_filename
onready var X509_key_path = "res://platinum-cert" + X509_key_filename

var CN = "PlatinumX509CertificateGenerator"
var O = "CiattixEngineering"
var C = "AR"
var not_before = "20210912000000"
var not_after = "20250912000000"

# Called when the node enters the scene tree for the first time.
func _ready():
	var directory = Directory.new()
	if directory.dir_exists("res://platinum-cert"):
		pass
	else:
		directory.make_dir("res://platinum-cert")
	Create509Cert()
	print("certificate created")
		
func Create509Cert():
	var CNOC = "CN=" + CN + "O=" + O + "C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
