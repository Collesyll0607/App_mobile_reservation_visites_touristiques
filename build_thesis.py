# -*- coding: utf-8 -*-
"""
Générateur officiel du Mémoire académique de Licence en Ingénierie Informatique
Université Assane Seck de Ziguinchor (UASZ)
Auteurs : Collé SYLL (Matricule : 202300489) & Ndeye Thiamba FAYE (Matricule : 202300288)
Encadrant : M. Lamine FATY, Enseignant-Chercheur, Département Informatique
"""

import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm, mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, Image, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas
import pypdf
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

# Couleurs institutionnelles UASZ & Casamance
COLOR_PRIMARY = colors.HexColor('#145C42')     # Vert émeraude officiel UASZ
COLOR_SECONDARY = colors.HexColor('#C8754D')   # Ocre terracotta Casamance
COLOR_DARK = colors.HexColor('#1E293B')        # Slate foncé
COLOR_MUTED = colors.HexColor('#64748B')       # Gris ardoise
COLOR_BG_LIGHT = colors.HexColor('#F8FAFC')    # Blanc cassé technique
COLOR_BORDER = colors.HexColor('#CBD5E1')      # Bordure tableau fine

class AcademicNumberedCanvas(canvas.Canvas):
    """Générateur de numérotation dynamique et en-têtes universitaires."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, total_pages):
        # La page de garde (page 1) n'a ni en-tête ni pied de page
        if self._pageNumber == 1:
            return

        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(COLOR_MUTED)

        # En-tête supérieur
        self.drawString(
            20 * mm, 
            286 * mm, 
            "Université Assane Seck de Ziguinchor — Licence en Ingénierie Informatique (Génie Logiciel)"
        )
        self.setStrokeColor(COLOR_BORDER)
        self.setLineWidth(0.5)
        self.line(20 * mm, 283 * mm, 190 * mm, 283 * mm)

        # Pied de page inférieur
        self.line(20 * mm, 16 * mm, 190 * mm, 16 * mm)
        self.drawString(
            20 * mm, 
            11 * mm, 
            "Mémoire de Projet Opérationnel : Collé SYLL & Ndeye Thiamba FAYE"
        )
        self.drawRightString(
            190 * mm, 
            11 * mm, 
            f"Page {self._pageNumber} sur {total_pages}"
        )
        self.restoreState()


def get_styles():
    base = getSampleStyleSheet()
    s = {}

    s['cover_univ'] = ParagraphStyle(
        'CoverUniv',
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=18,
        alignment=1,
        textColor=COLOR_PRIMARY,
        spaceAfter=5,
    )
    s['cover_sub'] = ParagraphStyle(
        'CoverSub',
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        alignment=1,
        textColor=COLOR_DARK,
        spaceAfter=2,
    )
    s['cover_dept'] = ParagraphStyle(
        'CoverDept',
        fontName='Helvetica',
        fontSize=10.5,
        leading=13.5,
        alignment=1,
        textColor=COLOR_DARK,
        spaceAfter=10,
    )
    s['cover_doc_type'] = ParagraphStyle(
        'CoverDocType',
        fontName='Helvetica-Bold',
        fontSize=12.5,
        leading=15,
        alignment=1,
        textColor=COLOR_SECONDARY,
        spaceAfter=10,
    )
    s['cover_title'] = ParagraphStyle(
        'CoverTitle',
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        alignment=1,
        textColor=COLOR_PRIMARY,
        spaceAfter=14,
    )
    s['cover_meta'] = ParagraphStyle(
        'CoverMeta',
        fontName='Helvetica',
        fontSize=9,
        leading=13.5,
        textColor=COLOR_DARK,
    )
    s['h1'] = ParagraphStyle(
        'ChapTitle',
        fontName='Helvetica-Bold',
        fontSize=14,
        leading=18,
        textColor=COLOR_PRIMARY,
        spaceBefore=14,
        spaceAfter=8,
        keepWithNext=True,
    )
    s['h2'] = ParagraphStyle(
        'SecTitle',
        fontName='Helvetica-Bold',
        fontSize=11.5,
        leading=15,
        textColor=COLOR_PRIMARY,
        spaceBefore=10,
        spaceAfter=5,
        keepWithNext=True,
    )
    s['h3'] = ParagraphStyle(
        'SubSecTitle',
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13.5,
        textColor=COLOR_SECONDARY,
        spaceBefore=7,
        spaceAfter=3,
        keepWithNext=True,
    )
    s['body'] = ParagraphStyle(
        'NormalBody',
        fontName='Helvetica',
        fontSize=9.2,
        leading=14,
        textColor=COLOR_DARK,
        alignment=4, # Justifié
        spaceAfter=6,
    )
    s['body_compact'] = ParagraphStyle(
        'CompactBody',
        fontName='Helvetica',
        fontSize=8.6,
        leading=12.6,
        textColor=COLOR_DARK,
        alignment=4,
        spaceAfter=4,
    )
    s['bullet'] = ParagraphStyle(
        'BulletBody',
        fontName='Helvetica',
        fontSize=9.2,
        leading=13.5,
        textColor=COLOR_DARK,
        leftIndent=14,
        firstLineIndent=-10,
        spaceAfter=3.5,
        alignment=4,
    )
    s['callout'] = ParagraphStyle(
        'CalloutText',
        fontName='Helvetica-Oblique',
        fontSize=9.2,
        leading=13.5,
        textColor=COLOR_PRIMARY,
        alignment=4,
    )
    s['code'] = ParagraphStyle(
        'CodeBlock',
        fontName='Courier',
        fontSize=7.6,
        leading=10.2,
        textColor=COLOR_DARK,
    )
    s['th'] = ParagraphStyle(
        'TableHead',
        fontName='Helvetica-Bold',
        fontSize=8.2,
        leading=11,
        textColor=colors.white,
    )
    s['td'] = ParagraphStyle(
        'TableCol',
        fontName='Helvetica',
        fontSize=8.2,
        leading=11,
        textColor=COLOR_DARK,
    )
    return s


def create_pdf_story(s, page_map=None):
    story = []

    def p_page(label):
        if page_map and label in page_map:
            return str(page_map[label])
        return "..."

    # =========================================================================
    # PAGE 1 : PAGE DE GARDE OFFICIELLE UASZ
    # =========================================================================
    story.append(Paragraph("UNIVERSITÉ ASSANE SECK DE ZIGUINCHOR", s['cover_univ']))
    story.append(Spacer(1, 2))

    logo_path = 'assets/images/logo_uasz.jpeg'
    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=2.4*cm, height=2.3*cm))
        story.append(Spacer(1, 2))

    story.append(Paragraph("UFR DES SCIENCES ET TECHNOLOGIES", s['cover_sub']))
    story.append(Paragraph("Département Informatique", s['cover_sub']))
    story.append(Paragraph("Licence en Ingénierie Informatique (Génie Logiciel)", s['cover_dept']))

    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph("MÉMOIRE DE FIN DE CYCLE — PROJET OPÉRATIONNEL", s['cover_doc_type']))
    story.append(Paragraph("THÈME DU PROJET :", s['cover_sub']))
    story.append(Paragraph(
        "« CONCEPTION ET IMPLÉMENTATION D’UNE APPLICATION MOBILE ET WEB DE DÉCOUVERTE ET DE RÉSERVATION DE VISITES TOURISTIQUES ET CULTURELLES EN CASAMANCE »",
        s['cover_title']
    ))

    binome_table = Table([
        [
            Paragraph("<b>Présenté et soutenu par :</b><br/>"
                      "• <b>Collé SYLL</b> (Matricule : 202300489)<br/>"
                      "• <b>Ndeye Thiamba FAYE</b> (Matricule : 202300288)", s['cover_meta']),
            Paragraph("<b>Sous la direction de :</b><br/>"
                      "• <b>M. Lamine FATY</b><br/>"
                      "Enseignant-Chercheur<br/>"
                      "Département Informatique, UASZ", s['cover_meta'])
        ]
    ], colWidths=[85*mm, 85*mm])
    binome_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(binome_table)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Membres du jury :</b>", s['cover_sub']))
    story.append(Spacer(1, 2))

    jury_table = Table([
        [Paragraph("Prénom et nom", s['th']), Paragraph("Grade", s['th']), Paragraph("Qualité", s['th']), Paragraph("Structure", s['th'])],
        [Paragraph("<b>Dr. ........................................</b>", s['td']), Paragraph("Maître de Conférences", s['td']), Paragraph("Président du Jury", s['td']), Paragraph("UASZ", s['td'])],
        [Paragraph("<b>M. Lamine FATY</b>", s['td']), Paragraph("Enseignant-Chercheur", s['td']), Paragraph("Encadrant / Rapporteur", s['td']), Paragraph("UASZ", s['td'])],
        [Paragraph("<b>Dr. ........................................</b>", s['td']), Paragraph("Enseignant-Chercheur", s['td']), Paragraph("Examinateur", s['td']), Paragraph("UASZ", s['td'])],
    ], colWidths=[55*mm, 42*mm, 43*mm, 30*mm])
    jury_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(jury_table)
    story.append(Spacer(1, 10))

    story.append(Paragraph("<b>Année universitaire : 2025 - 2026</b>", s['cover_sub']))
    story.append(PageBreak())

    # =========================================================================
    # PAGE 2 : DÉDICACES
    # =========================================================================
    story.append(Paragraph("DÉDICACES", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1, color=COLOR_PRIMARY, spaceAfter=14))

    story.append(Paragraph("<b>Dédicace de Collé SYLL :</b>", s['h2']))
    story.append(Paragraph(
        "Je dédie avec une profonde émotion et une gratitude infinie ce travail à mes très chers parents. "
        "Leurs sacrifices inestimables, leur affection sans faille, leurs prières quotidiennes et leurs conseils précieux "
        "ont guidé chacun de mes pas et ont forgé ma persévérance tout au long de mes études universitaires.",
        s['body']
    ))
    story.append(Paragraph(
        "À mes frères, sœurs et proches, dont la bienveillance constante et les encouragements continus ont constitué "
        "une source intarissable de réconfort et de motivation dans les moments d'exigence intellectuelle.",
        s['body']
    ))
    story.append(Paragraph(
        "À mon binôme <b>Ndeye Thiamba FAYE</b>, pour son esprit d'équipe exemplaire, sa rigueur intellectuelle, sa loyauté "
        "et la franche complicité professionnelle qui a rythmé nos journées d'ingénierie et de développement.",
        s['body']
    ))
    story.append(Spacer(1, 14))

    story.append(Paragraph("<b>Dédicace de Ndeye Thiamba FAYE :</b>", s['h2']))
    story.append(Paragraph(
        "Je dédie ce travail avec toute la tendresse de mon cœur à mes chers parents. Que ce mémoire soit l'humble "
        "témoignage de ma reconnaissance éternelle pour leur amour inconditionnel, leur dévouement sans limite et les sacrifices "
        "consentis pour mon éducation et ma réussite.",
        s['body']
    ))
    story.append(Paragraph(
        "À l'ensemble de ma famille, pour leur soutien moral indéfectible, leur patience et leur foi inébranlable en mes capacités.",
        s['body']
    ))
    story.append(Paragraph(
        "À ma binôme <b>Collé SYLL</b>, pour son dévouement remarquable, sa persévérance face aux défis d'architecture "
        "et la complémentarité constante qui a permis l'aboutissement de ce projet opérationnel.",
        s['body']
    ))
    story.append(PageBreak())

    # =========================================================================
    # PAGE 3 : REMERCIEMENTS
    # =========================================================================
    story.append(Paragraph("REMERCIEMENTS", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1, color=COLOR_PRIMARY, spaceAfter=12))

    story.append(Paragraph(
        "Au terme de ce projet opérationnel marquant l'aboutissement de notre formation en Licence d'Ingénierie Informatique, "
        "nous rendons grâce à <b>Dieu Tout-Puissant</b>, l'Omnipotent et le Miséricordieux, de nous avoir accordé la santé, la lucidité "
        "et la persévérance indispensables pour mener à bien cette entreprise académique et technique.",
        s['body']
    ))
    story.append(Paragraph(
        "Nous tenons à exprimer notre profonde et sincère gratitude à notre encadrant, <b>Monsieur Lamine FATY</b>, "
        "Enseignant-Chercheur au Département Informatique de l'Université Assane Seck de Ziguinchor. Nous le remercions chaleureusement "
        "pour sa disponibilité constante, sa rigueur scientifique, ses orientations méthodologiques avisées et son encadrement bienveillant "
        "qui ont largement contribué à la maturation de notre réflexion d'ingénieures logicielles.",
        s['body']
    ))
    story.append(Paragraph(
        "Nos remerciements les plus respectueux s'adressent également aux autorités académiques de l'<b>Université Assane Seck de Ziguinchor (UASZ)</b>, "
        "à la direction de l'UFR des Sciences et Technologies, ainsi qu'à l'ensemble du corps professoral et administratif du Département Informatique. "
        "Les connaissances théoriques et pratiques de haut niveau qui nous ont été transmises constituent le socle solide de notre future carrière professionnelle.",
        s['body']
    ))
    story.append(Paragraph(
        "Nous témoignons notre immense reconnaissance à nos familles respectives. Leurs sacrifices inlassables, leurs encouragements inaltérables "
        "et leur affection sincère ont été notre plus solide rempart face aux exigences universitaires.",
        s['body']
    ))
    story.append(Paragraph(
        "Nous remercions chaleureusement les acteurs touristiques et les guides locaux de Ziguinchor, d'Oussouye et de l'île de Carabane "
        "pour leur accueil enthousiaste et la pertinence de leurs retours de terrain sur les réalités du guidage.",
        s['body']
    ))
    story.append(Paragraph(
        "Enfin, nos pensées fraternelles vont à tous nos camarades de promotion de la <b>Licence en Ingénierie Informatique (Promotion 2025-2026)</b>, "
        "avec qui nous avons partagé des moments intenses d'apprentissage, d'émulation intellectuelle et de franche camaraderie.",
        s['body']
    ))
    story.append(PageBreak())

    # =========================================================================
    # PAGE 4 : RÉSUMÉ TECHNIQUE & TECHNICAL ABSTRACT (1 SEULE PAGE GARANTIE)
    # =========================================================================
    story.append(Paragraph("RÉSUMÉ TECHNIQUE", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1, color=COLOR_PRIMARY, spaceAfter=6))

    story.append(Paragraph(
        "Ce projet opérationnel porte sur la conception et l'implémentation d'une plateforme logicielle intégrée, multiplateforme (Mobile & Web), "
        "dédiée à la valorisation, à la découverte géolocalisée et à la réservation de visites touristiques et culturelles en région naturelle de Casamance (Sénégal). "
        "Face aux défis de l'enclavement géographique, de la prédominance des flux monétaires physiques et des contraintes d'intermittence des réseaux cellulaires en milieu rural, "
        "notre mission principale a consisté à bâtir un système distribué hautement résilient, couplant une expérience mobile intuitive à une traçabilité rigoureuse des flux touristiques et financiers.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "Sur le plan technologique, la solution repose sur une architecture 3-Tiers découplée : le front-end client est développé avec <b>Flutter/Dart</b>, "
        "garantissant une compatibilité native Android et Web ainsi qu'une réactivité hors-ligne intégrale grâce à <b>SharedPreferences</b>. "
        "Le back-end est architecturé autour d'une API REST <b>Spring Boot 3</b> sous <b>Java 21 OpenJDK</b>, orchestrant la logique métier et la persistance relationnelle "
        "au sein d'un cluster <b>MySQL 8</b> managé dans le cloud <b>Aiven</b> avec chiffrement SSL. Le déploiement continu est assuré par des conteneurs <b>Docker</b> "
        "hébergés sur la plateforme cloud <b>Render</b>.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "Le cycle de développement a suivi la méthodologie <b>Agile Scrum</b> en sept sprints. Les fonctionnalités majeures englobent un catalogue multimédia "
        "avec calcul géodésique de proximité (<b>formule de Haversine</b>), un formulaire de réservation réactif avec contrôles stricts de validité (FormState), "
        "la prise en charge des paiements mobiles (Wave, Orange Money) et en espèces au guichet, l'émission de billets électroniques à <b>QR code infalsifiable</b>, "
        "et un espace de contrôle guide sécurisé permettant la validation instantanée par scan et la traçabilité des encaissements sur site.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "<b>Mots-clés :</b> Génie Logiciel, Flutter, Spring Boot 3, MySQL 8, Architecture 3-Tiers, Résilience Hors-Ligne, Billetterie QR Code, Formule de Haversine, Cloud Render & Aiven, UASZ.",
        s['body_compact']
    ))
    story.append(Spacer(1, 4))

    story.append(Paragraph("TECHNICAL ABSTRACT", s['h2']))
    story.append(Paragraph(
        "This capstone project focuses on the engineering and implementation of an integrated cross-platform mobile and web application dedicated to the digital discovery "
        "and booking of cultural and ecological tours in Casamance (Senegal). Addressing challenges such as enclavement, pervasive cash dependencies, and intermittent cellular connectivity "
        "in rural heritage sites, our mission was to deliver a resilient distributed architecture ensuring service continuity, secure ticketing, and multi-actor accountability.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "The system implements a modern 3-Tier architecture: the client interface is built using <b>Flutter/Dart</b>, providing high-performance responsive UI for Android and Web "
        "alongside seamless offline capability backed by local caching (<b>SharedPreferences</b>). The server layer leverages <b>Spring Boot 3</b> and <b>Java 21 OpenJDK</b> "
        "to expose a stateless RESTful API, coupled with an <b>Aiven-managed MySQL 8</b> cloud database over enforced SSL tunnels. Containerized micro-services are continuously deployed "
        "through <b>Docker</b> onto <b>Render</b> cloud infrastructure.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "Development adhered to <b>Agile Scrum</b> principles across seven structured sprints. Delivered features comprise an interactive cultural catalog with <b>Haversine distance calculations</b>, "
        "a robust booking engine with fine-grained input validation, simulated mobile money (Wave, Orange Money) and cash payment workflows, dynamic tamper-proof <b>QR code digital ticket generation</b>, "
        "and a dedicated <b>Tour Guide Dashboard</b> offering real-time QR validation and audit tracking.",
        s['body_compact']
    ))
    story.append(Paragraph(
        "<b>Keywords :</b> Software Engineering, Flutter, Spring Boot, RESTful API, Offline-First Architecture, QR Code Ticketing, Mobile Money, Cultural Heritage, Casamance.",
        s['body_compact']
    ))
    story.append(PageBreak())

    # =========================================================================
    # PAGE 5 : GLOSSAIRE ET LISTE DES SIGLES
    # =========================================================================
    story.append(Paragraph("GLOSSAIRE ET LISTE DES SIGLES", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1, color=COLOR_PRIMARY, spaceAfter=8))

    story.append(Paragraph(
        "Le tableau ci-dessous répertorie l'ensemble des acronymes et termes techniques utilisés tout au long de ce mémoire, "
        "accompagnés de leur définition contextuelle en Génie Logiciel :",
        s['body']
    ))

    gloss_rows = [
        [Paragraph("Sigle", s['th']), Paragraph("Signification Développée", s['th']), Paragraph("Définition Contextuelle dans le Projet", s['th'])],
        [Paragraph("<b>API</b>", s['td']), Paragraph("Application Programming Interface", s['td']), Paragraph("Interface logicielle standardisée permettant la communication HTTP entre le frontend Flutter et le backend Spring Boot.", s['td'])],
        [Paragraph("<b>CI/CD</b>", s['td']), Paragraph("Continuous Integration / Deployment", s['td']), Paragraph("Pratique d'automatisation de la validation du code, du build Docker et du déploiement continu sur Render.", s['td'])],
        [Paragraph("<b>DAO</b>", s['td']), Paragraph("Data Access Object", s['td']), Paragraph("Patron de conception encapsulant l'accès et les requêtes vers la base de données relationnelle.", s['td'])],
        [Paragraph("<b>DTO</b>", s['td']), Paragraph("Data Transfer Object", s['td']), Paragraph("Objet de transfert de données allégeant les payloads JSON et isolant les entités de persistance.", s['td'])],
        [Paragraph("<b>GL</b>", s['td']), Paragraph("Génie Logiciel", s['td']), Paragraph("Discipline d'ingénierie dédiée à la conception méthodique, modulaire et vérifiable de logiciels de qualité.", s['td'])],
        [Paragraph("<b>GPS</b>", s['td']), Paragraph("Global Positioning System", s['td']), Paragraph("Système satellitaire de géolocalisation exploité pour le calcul des distances par l'algorithme d'Haversine.", s['td'])],
        [Paragraph("<b>HTTP / HTTPS</b>", s['td']), Paragraph("Hypertext Transfer Protocol (Secure)", s['td']), Paragraph("Protocole de communication sécurisé par chiffrement TLS régissant les requêtes entre client et API.", s['td'])],
        [Paragraph("<b>JSON</b>", s['td']), Paragraph("JavaScript Object Notation", s['td']), Paragraph("Format textuel léger et universel de sérialisation et d'échange de données structurées.", s['td'])],
        [Paragraph("<b>JPA</b>", s['td']), Paragraph("Jakarta Persistence API", s['td']), Paragraph("Spécification standard de gestion de la persistance des données relationnelles en environnement Java.", s['td'])],
        [Paragraph("<b>MVC</b>", s['td']), Paragraph("Modèle-Vue-Contrôleur", s['td']), Paragraph("Patron architectural dissociant les données (Modèle), l'interface (Vue) et la logique applicative (Contrôleur).", s['td'])],
        [Paragraph("<b>Nginx</b>", s['td']), Paragraph("Engine X", s['td']), Paragraph("Serveur web et reverse proxy assurant la distribution de Flutter Web et la redirection fluide des requêtes API.", s['td'])],
        [Paragraph("<b>ORM</b>", s['td']), Paragraph("Object-Relational Mapping", s['td']), Paragraph("Technologie (Hibernate) mappant les tables relationnelles MySQL sur des entités Java métier.", s['td'])],
        [Paragraph("<b>PWA</b>", s['td']), Paragraph("Progressive Web App", s['td']), Paragraph("Application web installable directement sur smartphone, s'exécutant en plein écran sans barre de navigateur.", s['td'])],
        [Paragraph("<b>QR Code</b>", s['td']), Paragraph("Quick Response Code", s['td']), Paragraph("Code-barres bidimensionnel matriciel encodant la clé cryptographique unique d'authentification du billet.", s['td'])],
        [Paragraph("<b>REST</b>", s['td']), Paragraph("Representational State Transfer", s['td']), Paragraph("Style architectural sans état exploitant les verbes HTTP (GET, POST, PATCH) pour manipuler les ressources.", s['td'])],
        [Paragraph("<b>SDK</b>", s['td']), Paragraph("Software Development Kit", s['td']), Paragraph("Ensemble d'outils et de bibliothèques fourni par Google pour la compilation des applications Flutter/Dart.", s['td'])],
        [Paragraph("<b>SGBD</b>", s['td']), Paragraph("Système de Gestion de Base de Données", s['td']), Paragraph("Logiciel serveur (MySQL 8) garantissant le stockage sécurisé, la cohérence ACID et l'accès concurrentiel.", s['td'])],
        [Paragraph("<b>SSL/TLS</b>", s['td']), Paragraph("Secure Sockets Layer / TLS", s['td']), Paragraph("Protocole cryptographique garantissant la confidentialité et l'intégrité des flux réseau chiffrés.", s['td'])],
        [Paragraph("<b>UASZ</b>", s['td']), Paragraph("Université Assane Seck de Ziguinchor", s['td']), Paragraph("Institution universitaire publique d'excellence d'accueil de notre formation en Licence d'Informatique.", s['td'])],
        [Paragraph("<b>UI / UX</b>", s['td']), Paragraph("User Interface / User Experience", s['td']), Paragraph("Ensemble des composantes visuelles et ergonomiques régissant l'interaction homme-machine.", s['td'])],
        [Paragraph("<b>UML</b>", s['td']), Paragraph("Unified Modeling Language", s['td']), Paragraph("Langage visuel standardisé de modélisation orientée objet pour l'analyse et la conception logicielle.", s['td'])],
    ]
    t_gloss = Table(gloss_rows, colWidths=[28*mm, 52*mm, 90*mm])
    t_gloss.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_gloss)
    story.append(PageBreak())

    # =========================================================================
    # PAGE 6 : SOMMAIRE GÉNÉRAL & TABLES D'ILLUSTRATIONS
    # =========================================================================
    story.append(Paragraph("SOMMAIRE GÉNÉRAL", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1, color=COLOR_PRIMARY, spaceAfter=8))

    somm_rows = [
        [Paragraph("<b>DÉDICACES</b>", s['body']), Paragraph(f"<b>{p_page('dedicaces')}</b>", s['body'])],
        [Paragraph("<b>REMERCIEMENTS</b>", s['body']), Paragraph(f"<b>{p_page('remerciements')}</b>", s['body'])],
        [Paragraph("<b>RÉSUMÉ TECHNIQUE & ABSTRACT</b>", s['body']), Paragraph(f"<b>{p_page('resume')}</b>", s['body'])],
        [Paragraph("<b>GLOSSAIRE ET LISTE DES SIGLES</b>", s['body']), Paragraph(f"<b>{p_page('glossaire')}</b>", s['body'])],
        [Paragraph("<b>SOMMAIRE GÉNÉRAL & TABLES</b>", s['body']), Paragraph(f"<b>{p_page('sommaire')}</b>", s['body'])],
        [Paragraph("<b>INTRODUCTION GÉNÉRALE</b>", s['body']), Paragraph(f"<b>{p_page('intro')}</b>", s['body'])],
        [Paragraph("<b>CHAPITRE 1 : GESTION DE PROJET ET APPROCHE MÉTHODOLOGIQUE</b>", s['body']), Paragraph(f"<b>{p_page('chap1')}</b>", s['body'])],
        [Paragraph("&nbsp;&nbsp;1.1 Contexte technique du projet en Génie Logiciel", s['body']), Paragraph(p_page('chap1'), s['body'])],
        [Paragraph("&nbsp;&nbsp;1.2 Méthodologie Agile Scrum adoptée", s['body']), Paragraph(p_page('sec12'), s['body'])],
        [Paragraph("&nbsp;&nbsp;1.3 Exigences de qualité logicielle et métriques", s['body']), Paragraph(p_page('sec13'), s['body'])],
        [Paragraph("&nbsp;&nbsp;1.4 Justification des choix technologiques et méthodologiques", s['body']), Paragraph(p_page('sec14'), s['body'])],
        [Paragraph("&nbsp;&nbsp;1.5 Répartition des rôles et matrice des responsabilités (RACI)", s['body']), Paragraph(p_page('sec15'), s['body'])],
        [Paragraph("<b>CHAPITRE 2 : SPÉCIFICATION ET ANALYSE DES BESOINS (CAHIER DES CHARGES)</b>", s['body']), Paragraph(f"<b>{p_page('chap2')}</b>", s['body'])],
        [Paragraph("&nbsp;&nbsp;2.1 Recueil des besoins et étude d'opportunité en Casamance", s['body']), Paragraph(p_page('chap2'), s['body'])],
        [Paragraph("&nbsp;&nbsp;2.2 Identification des acteurs, User Stories et critères d'acceptation", s['body']), Paragraph(p_page('sec22'), s['body'])],
        [Paragraph("&nbsp;&nbsp;2.3 Spécification détaillée des besoins fonctionnels", s['body']), Paragraph(p_page('sec23'), s['body'])],
        [Paragraph("&nbsp;&nbsp;2.4 Spécification des besoins non fonctionnels", s['body']), Paragraph(p_page('sec24'), s['body'])],
        [Paragraph("&nbsp;&nbsp;2.5 Modélisation UML de l'analyse (Cas d'utilisation, Séquences, États)", s['body']), Paragraph(p_page('sec25'), s['body'])],
        [Paragraph("&nbsp;&nbsp;2.6 Contraintes opérationnelles et sécuritaires du système", s['body']), Paragraph(p_page('sec26'), s['body'])],
        [Paragraph("<b>CHAPITRE 3 : CONCEPTION DU SYSTÈME (GÉNIE LOGICIEL)</b>", s['body']), Paragraph(f"<b>{p_page('chap3')}</b>", s['body'])],
        [Paragraph("&nbsp;&nbsp;3.1 Architecture logicielle globale 3-Tiers", s['body']), Paragraph(p_page('chap3'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.2 Diagramme de composants du système distribué", s['body']), Paragraph(p_page('sec32'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.3 Diagramme de packages et modularité", s['body']), Paragraph(p_page('sec33'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.4 Diagramme de déploiement physique et cloud", s['body']), Paragraph(p_page('sec34'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.5 Diagramme de classes métier", s['body']), Paragraph(p_page('sec35'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.6 Diagramme d'objets (instanciation à l'exécution)", s['body']), Paragraph(p_page('sec36'), s['body'])],
        [Paragraph("&nbsp;&nbsp;3.7 Design Patterns et patrons d'architecture appliqués", s['body']), Paragraph(p_page('sec37'), s['body'])],
        [Paragraph("<b>CHAPITRE 4 : IMPLÉMENTATION ET TESTS FONCTIONNELS</b>", s['body']), Paragraph(f"<b>{p_page('chap4')}</b>", s['body'])],
        [Paragraph("&nbsp;&nbsp;4.1 Environnement et pile technologique de réalisation", s['body']), Paragraph(p_page('chap4'), s['body'])],
        [Paragraph("&nbsp;&nbsp;4.2 Développement de la solution et modules applicatifs clés", s['body']), Paragraph(p_page('sec42'), s['body'])],
        [Paragraph("&nbsp;&nbsp;4.3 Description approfondie des algorithmes essentiels", s['body']), Paragraph(p_page('sec43'), s['body'])],
        [Paragraph("&nbsp;&nbsp;4.4 Gestion des exceptions et résilience réseau", s['body']), Paragraph(p_page('sec44'), s['body'])],
        [Paragraph("&nbsp;&nbsp;4.5 Stratégie de tests et validation fonctionnelle (100 % de succès)", s['body']), Paragraph(p_page('sec45'), s['body'])],
        [Paragraph("<b>CONCLUSION GÉNÉRALE ET PERSPECTIVES</b>", s['body']), Paragraph(f"<b>{p_page('conclusion')}</b>", s['body'])],
        [Paragraph("<b>BIBLIOGRAPHIE ET WEBOGRAPHIE</b>", s['body']), Paragraph(f"<b>{p_page('biblio')}</b>", s['body'])],
        [Paragraph("<b>ANNEXES TECHNIQUES</b>", s['body']), Paragraph(f"<b>{p_page('annexes')}</b>", s['body'])],
    ]
    t_somm = Table(somm_rows, colWidths=[150*mm, 20*mm])
    t_somm.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ALIGN', (1,0), (1,-1), 'RIGHT'),
        ('TOPPADDING', (0,0), (-1,-1), 1),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(t_somm)
    story.append(Spacer(1, 8))

    story.append(Paragraph("LISTE DES FIGURES ET ILLUSTRATIONS", s['h2']))
    fig_rows = [
        [Paragraph("Figure 2.1 : Diagramme UML global des Cas d'Utilisation du système", s['td']), Paragraph(f"Page {p_page('fig21')}", s['td'])],
        [Paragraph("Figure 2.2 : Diagramme de Séquence Système : Réservation et Paiement mobile", s['td']), Paragraph(f"Page {p_page('fig22')}", s['td'])],
        [Paragraph("Figure 2.3 : Diagramme de Séquence Système : Contrôle d'accès et scan QR Guide", s['td']), Paragraph(f"Page {p_page('fig23')}", s['td'])],
        [Paragraph("Figure 2.4 : Diagramme d'États-Transitions du cycle de vie d'une réservation", s['td']), Paragraph(f"Page {p_page('fig24')}", s['td'])],
        [Paragraph("Figure 3.1 : Architecture logicielle globale 3-Tiers orientée services", s['td']), Paragraph(f"Page {p_page('fig31')}", s['td'])],
        [Paragraph("Figure 3.2 : Diagramme de composants du système distribué (Mobile & API)", s['td']), Paragraph(f"Page {p_page('fig32')}", s['td'])],
        [Paragraph("Figure 3.3 : Diagramme de packages et modularité Flutter et Spring Boot", s['td']), Paragraph(f"Page {p_page('fig33')}", s['td'])],
        [Paragraph("Figure 3.4 : Diagramme de déploiement Cloud (Docker Render & MySQL Aiven)", s['td']), Paragraph(f"Page {p_page('fig34')}", s['td'])],
        [Paragraph("Figure 3.5 : Diagramme de classes métier orienté objet", s['td']), Paragraph(f"Page {p_page('fig35')}", s['td'])],
        [Paragraph("Figure 3.6 : Diagramme d'objets instanciés en mémoire lors d'une validation", s['td']), Paragraph(f"Page {p_page('fig36')}", s['td'])],
    ]
    t_fig = Table(fig_rows, colWidths=[145*mm, 25*mm])
    t_fig.setStyle(TableStyle([
        ('TOPPADDING', (0,0), (-1,-1), 1),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('ALIGN', (1,0), (1,-1), 'RIGHT'),
    ]))
    story.append(t_fig)
    story.append(PageBreak())

    # =========================================================================
    # INTRODUCTION GÉNÉRALE
    # =========================================================================
    story.append(Paragraph("INTRODUCTION GÉNÉRALE", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("1. Contexte du projet", s['h2']))
    story.append(Paragraph(
        "La région naturelle de la Casamance, située dans le sud du Sénégal, dispose d'un patrimoine naturel, historique et culturel d'une richesse exceptionnelle. "
        "Bordée par le fleuve Casamance et l'océan Atlantique, elle abrite des écosystèmes préservés de mangrove, des sanctuaires traditionnels animistes au cœur "
        "du royaume d'Oussouye, ainsi que des vestiges coloniaux classés tels que l'île historique de Carabane ou le musée d'art diola de Kadioute à Boucotte. "
        "Cette biodiversité et ce foisonnement culturel font de la Casamance l'une des destinations phares du tourisme sénégalais, reconnue pour son potentiel écotouristique et solidaire de premier plan.",
        s['body']
    ))
    story.append(Paragraph(
        "Toutefois, en dépit de ces atouts remarquables, l'écosystème touristique régional demeure confronté à des contraintes structurelles majeures. "
        "L'enclavement géographique de certains sites insulaires ou forestiers, l'absence de canaux numériques centralisés d'information et la prédominance "
        "exclusive des transactions monétaires en espèces créent des frictions importantes pour les visiteurs nationaux et internationaux. Parallèlement, "
        "les guides touristiques locaux et les gestionnaires de campements villageois peinent à planifier leurs prestations, à anticiper les flux de visiteurs "
        "et à sécuriser leurs revenus en l'absence d'outils numériques modernes de réservation et de contrôle d'accès.",
        s['body']
    ))
    story.append(Paragraph(
        "Dans ce contexte, la diffusion accélérée de la téléphonie mobile au Sénégal et l'adoption massive des services de paiement mobile (Mobile Money tels que "
        "Wave et Orange Money) ouvrent des perspectives inédites. La transformation numérique du secteur touristique casamançais représente une opportunité stratégique "
        "pour désenclaver les territoires ruraux, valoriser durablement le patrimoine communautaire et fluidifier l'expérience des voyageurs à travers une solution "
        "logicielle tout-en-un, accessible et résiliente.",
        s['body']
    ))

    story.append(Paragraph("2. Problématique technique de Génie Logiciel", s['h2']))
    story.append(Paragraph(
        "D'un point de vue strict du Génie Logiciel, la conception et le déploiement d'une telle solution posent des défis d'ingénierie stimulants. "
        "En milieu rural casamançais, la couverture réseau cellulaire 3G/4G demeure fréquemment instable, voire totalement absente sur certains sites reculés "
        "(excursion en pirogue vers Carabane, sentiers forestiers d'Enampore). Dès lors, une application mobile strictement dépendante d'une connexion permanente "
        "à un serveur distant s'avérerait totalement inopérante.",
        s['body']
    ))

    t_prob = Table([[
        Paragraph(
            "<b>Problématique Centrale de Génie Logiciel :</b><br/>"
            "<i>« Comment concevoir et implémenter une architecture logicielle distribuée (Mobile et Web), découplée et sécurisée, "
            "capable d'assurer la continuité absolue de service en mode déconnecté (Offline-First), de garantir l'infalsifiabilité des billets "
            "numériques par encodage QR cryptographique et de réconcilier de manière fiable les flux financiers électroniques et physiques "
            "pour la valorisation du patrimoine touristique de la Casamance ? »</i>",
            s['callout']
        )
    ]], colWidths=[170*mm])
    t_prob.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_prob)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3. Objectifs du rapport", s['h2']))
    story.append(Paragraph(
        "L'objectif premier de ce rapport est de démontrer comment nous avons mobilisé et articulé les méthodes, les principes directeurs "
        "et les meilleures pratiques du Génie Logiciel pour concevoir, modéliser, réaliser et valider une solution logicielle complète, robuste et évolutive :",
        s['body']
    ))
    story.append(Paragraph("• <b>L'analyse orientée objet avec UML</b> : modélisation formelle des exigences, des cas d'utilisation et des scénarios dynamiques.", s['bullet']))
    story.append(Paragraph("• <b>Le découplage architectural en couches 3-Tiers</b> : séparation étanche entre la présentation Flutter, le serveur Spring Boot et la persistance relationnelle MySQL.", s['bullet']))
    story.append(Paragraph("• <b>L'application rigoureuse des patrons de conception (Design Patterns)</b> : Singleton, Provider/Observer, DTO, Repository, IoC/DI et Factory Method.", s['bullet']))
    story.append(Paragraph("• <b>La programmation réactive et le typage fort</b> : garantie absolue contre les pointeurs nuls grâce au sound null safety de Dart 3 et à Java 21.", s['bullet']))
    story.append(Paragraph("• <b>La validation méthodique par tests automatisés</b> : couverture complète des modèles, des calculs géodésiques et des scénarios de contrôle d'accès.", s['bullet']))

    story.append(Paragraph("4. Annonce du plan", s['h2']))
    story.append(Paragraph(
        "Pour répondre fidèlement aux exigences académiques du modèle officiel de projet tutoré de l'UASZ, le présent mémoire est articulé en quatre chapitres complémentaires :",
        s['body']
    ))
    story.append(Paragraph("• <b>Chapitre 1 : Gestion de projet et approche méthodologique</b> présente l'environnement technique, détaille la démarche Agile Scrum cadencée en sept sprints, explicite les critères d'assurance qualité et formalise la matrice des responsabilités RACI.", s['bullet']))
    story.append(Paragraph("• <b>Chapitre 2 : Spécification et Analyse des besoins (Cahier des charges)</b> synthétise le recueil d'exigences sur le terrain, détaille les User Stories et modélise formellement le système à l'aide des diagrammes UML.", s['bullet']))
    story.append(Paragraph("• <b>Chapitre 3 : Conception du système (Génie Logiciel)</b> expose l'architecture globale 3-tiers, les diagrammes structurels de composants, de packages, de déploiement cloud et de classes, et justifie les patrons de conception mobilisés.", s['bullet']))
    story.append(Paragraph("• <b>Chapitre 4 : Implémentation et tests fonctionnels</b> documente la réalisation concrète de l'application Flutter et du backend Spring Boot, détaille les algorithmes géodésiques et cryptographiques, explicite la gestion des exceptions et expose les résultats probants de la campagne de tests (100 % de succès).", s['bullet']))
    story.append(PageBreak())

    # =========================================================================
    # CHAPITRE 1 : GESTION DE PROJET ET APPROCHE MÉTHODOLOGIQUE
    # =========================================================================
    story.append(Paragraph("CHAPITRE 1 : GESTION DE PROJET ET APPROCHE MÉTHODOLOGIQUE", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("1.1 Contexte technique du projet en Génie Logiciel", s['h2']))
    story.append(Paragraph(
        "Dans le cadre de notre formation en Licence d'Ingénierie Informatique, filière Génie Logiciel (GL), la réalisation de ce projet opérationnel s'inscrit "
        "au carrefour de plusieurs disciplines majeures de l'informatique moderne : l'ingénierie des exigences, l'architecture orientée services (SOA), "
        "le développement multiplateforme réactif et l'automatisation du déploiement cloud continu.",
        s['body']
    ))
    story.append(Paragraph(
        "Un projet logiciel dédié au tourisme communautaire en Afrique subsaharienne présente des contraintes techniques spécifiques qui dépassent le cadre "
        "conventionnel des simples applications de bureau. Le système doit s'exécuter avec fluidité sur une grande diversité de terminaux clients (smartphones Android "
        "d'entrée de gamme, tablettes, navigateurs web modernes), tolérer les coupures réseau fréquentes et garantir l'intégrité transactionnelle lors des réservations. "
        "Dès lors, le recours aux méthodes formelles du Génie Logiciel est indispensable pour maîtriser la dette technique, garantir la maintenabilité du code source "
        "et permettre le passage à l'échelle futur de la plateforme.",
        s['body']
    ))

    story.append(Paragraph("1.2 Méthodologie Agile Scrum adoptée", s['h2']))
    story.append(Paragraph(
        "Pour assurer une progression continue, maîtrisée et parfaitement réactive face aux ajustements fonctionnels, notre binôme a adopté la méthodologie "
        "<b>Agile Scrum</b>. Cette démarche itérative et incrémentale a permis de découper la réalisation en cycles courts (Sprints) d'une à deux semaines, débouchant "
        "chacun sur un incrément logiciel testé, documenté et immédiatement exécutable.",
        s['body']
    ))
    story.append(Paragraph("Dans notre organisation collaborative à deux étudiantes, les rituels Scrum ont été adaptés avec rigueur :", s['body']))
    story.append(Paragraph("• <b>Product Backlog</b> : Répertoire hiérarchisé de toutes les fonctionnalités exprimées sous forme de User Stories, priorisées selon leur valeur métier et leur complexité technique.", s['bullet']))
    story.append(Paragraph("• <b>Sprint Planning</b> : Réunion de cadrage au début de chaque itération pour sélectionner les User Stories, estimer la charge en points d'effort et ventiler les tâches techniques.", s['bullet']))
    story.append(Paragraph("• <b>Daily Standups</b> : Mises au point quotidiennes synchrones de 15 minutes pour partager les accomplissements, lever les points de blocage et synchroniser les branches Git.", s['bullet']))
    story.append(Paragraph("• <b>Sprint Review et Rétrospective</b> : Démonstration fonctionnelle de l'incrément produit au terme de chaque sprint, analyse critique des difficultés et ajustement pour l'itération suivante.", s['bullet']))

    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>Cadence et déroulement des sept sprints du projet :</b>", s['h3']))
    story.append(Paragraph("• <b>Sprint 1</b> : Cadrage général, architecture 3-Tiers, initialisation du dépôt Git GitHub et structuration du catalogue des patrimoines de Casamance.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 2</b> : Formulaire interactif de réservation et développement du moteur de calcul géodésique de proximité par la formule de Haversine.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 3</b> : Double persistance locale (SharedPreferences), gestion des statuts de réservation et écran de consultation 'Mes Réservations'.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 4</b> : Conception du module des favoris hors-ligne et isolation étanche du cache local par compte utilisateur connecté.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 5</b> : Développement de l'Espace Guide interactif, scan de QR Code, contrôle d'accès anti-rejeu et réconciliation financière sur site.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 6</b> : Perfectionnement de la billetterie numérique : génération de reçus, partage natif mobile et affichage des dates françaises standardisées.", s['bullet']))
    story.append(Paragraph("• <b>Sprint 7</b> : Validation stricte des formulaires (FormState), déploiement cloud managé (Aiven MySQL & Render Web Services) et audit qualité final.", s['bullet']))

    story.append(Paragraph("1.3 Exigences de qualité logicielle et métriques", s['h2']))
    story.append(Paragraph(
        "La qualité logicielle a été érigée en contrainte non négociable tout au long du cycle de vie du projet. Conformément aux standards <b>ISO/IEC 25010</b> "
        "sur la qualité des systèmes logiciels, nous avons concentré nos efforts sur quatre métriques fondamentales :",
        s['body']
    ))
    story.append(Paragraph("1. <b>Couverture des tests et non-régression</b> : Respect de la pyramide des tests avec des tests unitaires pour la logique métier pure (calculs de prix, sérialisation JSON, algorithme de Haversine), des tests de widgets pour les formulaires et des tests d'intégration simulant le cycle complet de réservation et de validation guide.", s['bullet']))
    story.append(Paragraph("2. <b>Maîtrise de la dette technique</b> : Application du principe du Boy Scout (« Toujours laisser le code plus propre que vous ne l'avez trouvé »). Chaque duplication ou anomalie a fait l'objet d'un refactoring immédiat.", s['bullet']))
    story.append(Paragraph("3. <b>Respect des normes de codage et typage fort</b> : Le projet Flutter applique rigoureusement le Dart Style Guide (nommage camelCase/PascalCase, 'const' constructeurs pour optimiser l'arbre de rendu) et exploite la 'sound null safety' pour éliminer à la compilation les erreurs de pointeur nul. Côté backend, le code respecte les conventions Google Java Style.", s['bullet']))
    story.append(Paragraph("4. <b>Analyse statique continue</b> : L'exécution systématique de 'flutter analyze lib/' avant chaque commit garantit un score parfait : <b>0 issue (0 warning, 0 error)</b>.", s['bullet']))

    story.append(Paragraph("1.4 Justification des choix technologiques et méthodologiques", s['h2']))
    story.append(Paragraph(
        "Chaque composant technologique de notre architecture a été sélectionné à la suite d'une analyse comparative multicritères prenant en compte "
        "les performances d'exécution, la maturité de l'écosystème, la documentation et l'adéquation au contexte ouest-africain :",
        s['body']
    ))

    t_tech = Table([
        [Paragraph("Composant", s['th']), Paragraph("Choix Retenu", s['th']), Paragraph("Alternatives Étudiées", s['th']), Paragraph("Critères Déterminants de Justification", s['th'])],
        [
            Paragraph("<b>Framework Client</b>", s['td']),
            Paragraph("<b>Flutter 3.x (Dart 3)</b>", s['td']),
            Paragraph("React Native, Android Natif (Kotlin)", s['td']),
            Paragraph("Moteur de rendu natif (Impeller/Skia) à 60 FPS sans pont JS, partage de 100 % du code source entre Mobile et Web, robustesse du typage fort Dart.", s['td'])
        ],
        [
            Paragraph("<b>Serveur Backend</b>", s['td']),
            Paragraph("<b>Spring Boot 3 (Java 21)</b>", s['td']),
            Paragraph("Node.js / Express, Django (Python)", s['td']),
            Paragraph("Robustesse industrielle, typage statique de Java 21, écosystème de persistance mature (Spring Data JPA, Hibernate), transactions fiables.", s['td'])
        ],
        [
            Paragraph("<b>Base de Données</b>", s['td']),
            Paragraph("<b>MySQL 8 (InnoDB)</b>", s['td']),
            Paragraph("MongoDB, PostgreSQL", s['td']),
            Paragraph("Respect strict des propriétés ACID indispensables pour la gestion des transactions financières et des billets, parfaite compatibilité cloud.", s['td'])
        ],
        [
            Paragraph("<b>Conteneurisation & Cloud</b>", s['td']),
            Paragraph("<b>Docker, Render & Aiven</b>", s['td']),
            Paragraph("Serveur VPS dédié, Heroku, Firebase", s['td']),
            Paragraph("Déploiement reproductible sans biais machine, base MySQL managée avec chiffrement SSL obligatoire sur Aiven, hébergement web conteneurisé gratuit sur Render.", s['td'])
        ],
    ], colWidths=[32*mm, 35*mm, 40*mm, 63*mm])
    t_tech.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_tech)
    story.append(Spacer(1, 8))

    story.append(Paragraph("1.5 Répartition des rôles et matrice des responsabilités (RACI)", s['h2']))
    story.append(Paragraph(
        "La réussite d'un projet de Génie Logiciel mené en binôme repose sur une gouvernance équilibrée, une communication transparente "
        "et une spécialisation claire des responsabilités évitant les redondances de code. Notre binôme s'est structuré autour de deux pôles d'excellence :",
        s['body']
    ))
    story.append(Paragraph("• <b>Collé SYLL</b> : Direction architecturale globale, modélisation de la base de données relationnelle, développement du backend Spring Boot 3, implémentation des contrôleurs REST, gestion de l'authentification et configuration du déploiement Docker sur Render et Aiven.", s['bullet']))
    story.append(Paragraph("• <b>Ndeye Thiamba FAYE</b> : Expérience utilisateur mobile (UI/UX Material 3), moteur de réservation réactif avec validation de saisie FormState, algorithme d'encodage et de rendu du billet QR Code, persistance locale SharedPreferences et développement de l'Espace Guide interactif.", s['bullet']))

    t_raci = Table([
        [Paragraph("Domaine d'Activité / Tâche d'Ingénierie", s['th']), Paragraph("Collé SYLL", s['th']), Paragraph("Ndeye Thiamba FAYE", s['th'])],
        [Paragraph("Étude d'opportunité & Recueil des besoins de terrain", s['td']), Paragraph("A (Accountable)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Conception de l'architecture 3-Tiers & Modélisation UML", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("A (Accountable)", s['td'])],
        [Paragraph("Développement du catalogue touristique & calcul géodésique", s['td']), Paragraph("C (Consulted)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Moteur de réservation & Validation stricte des formulaires", s['td']), Paragraph("C (Consulted)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Système de paiement simulé (Wave, OM, Espèces sur place)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("A (Accountable)", s['td'])],
        [Paragraph("Génération, encodage et partage du billet QR Code", s['td']), Paragraph("C (Consulted)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Espace Guide : Scan QR, traçabilité et réconciliation de caisse", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("A (Accountable)", s['td'])],
        [Paragraph("Persistance locale SharedPreferences & Mode hors-ligne", s['td']), Paragraph("C (Consulted)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Backend Spring Boot 3, API REST & Schéma MySQL", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("C (Consulted)", s['td'])],
        [Paragraph("Déploiement Cloud (Docker, Render, Aiven MySQL SSL)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("I (Informed)", s['td'])],
        [Paragraph("Assurance qualité logicielle, tests automatisés & flutter analyze", s['td']), Paragraph("A (Accountable)", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
        [Paragraph("Rédaction du mémoire académique et préparation de soutenance", s['td']), Paragraph("<b>R (Responsible)</b>", s['td']), Paragraph("<b>R (Responsible)</b>", s['td'])],
    ], colWidths=[90*mm, 40*mm, 40*mm])
    t_raci.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_raci)
    story.append(PageBreak())

    # =========================================================================
    # CHAPITRE 2 : SPÉCIFICATION ET ANALYSE DES BESOINS
    # =========================================================================
    story.append(Paragraph("CHAPITRE 2 : SPÉCIFICATION ET ANALYSE DES BESOINS (CAHIER DES CHARGES)", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("2.1 Recueil des besoins et étude d'opportunité en Casamance", s['h2']))
    story.append(Paragraph(
        "La phase initiale d'ingénierie des exigences a mobilisé une démarche d'investigation rigoureuse combinant entretiens semi-directifs, "
        "questionnaires de terrain et observations in situ auprès des parties prenantes du tourisme dans les localités de Ziguinchor, Oussouye, "
        "Boucotte, Enampore et Cap Skirring :",
        s['body']
    ))
    story.append(Paragraph("1. <b>Les guides touristiques accrédités et associations villageoises</b> : Ils ont souligné la difficulté récurrente de gérer les réservations par de simples appels téléphoniques ou messages WhatsApp, générateurs fréquents de doublons, de créneaux conflictuels et d'annulations de dernière minute non dédommagées. Ils ont exprimé le besoin pressant d'un outil mobile ergonomique leur permettant de visualiser le planning journalier, d'authentifier instantanément les visiteurs par QR code et d'encaisser les prestations sur place en toute transparence.", s['body']))
    story.append(Paragraph("2. <b>Les touristes nationaux et internationaux</b> : L'enquête a révélé une forte frustration liée au manque de visibilité centralisée sur les richesses patrimoniales régionales. Les visiteurs souhaitent pouvoir explorer les sites avec des données vérifiées (histoire, localisation GPS, tarifs officiels), réserver en quelques clics via leur compte Mobile Money (Wave, Orange Money) et conserver leurs billets accessibles sur leur téléphone même en zone sans réseau.", s['body']))
    story.append(Paragraph("3. <b>Les gestionnaires de sites et conservateurs</b> : Leurs attentes prioritaires concernent la traçabilité des flux financiers, la valorisation du patrimoine matériel et immatériel, et la fiabilisation des statistiques de fréquentation.", s['body']))

    story.append(Paragraph("2.2 Identification des acteurs, User Stories et critères d'acceptation", s['h2']))
    story.append(Paragraph("L'analyse du domaine métier a permis d'isoler trois acteurs principaux interagissant avec le système :", s['body']))
    story.append(Paragraph("• <b>Le Touriste (Utilisateur principal)</b> : Visiteur individuel ou chef de groupe souhaitant découvrir le patrimoine casamançais, planifier des visites guidées, effectuer ses paiements et gérer ses billets numériques sur son terminal.", s['bullet']))
    story.append(Paragraph("• <b>Le Guide Touristique (Utilisateur opérationnel)</b> : Professionnel accrédité responsable de la conduite des visites. Il dispose d'un espace sécurisé pour contrôler et valider les billets par scan QR code, consigner les paiements en espèces et suivre ses indicateurs.", s['bullet']))
    story.append(Paragraph("• <b>L'Administrateur du Système (Gestionnaire technique)</b> : Responsable de la maintenance de la plateforme, de l'actualisation du catalogue patrimonial et de la supervision globale des flux.", s['bullet']))

    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>Tableau des User Stories formalisées selon la syntaxe Gherkin (Étant donné / Quand / Alors) :</b>", s['h3']))

    t_us = Table([
        [Paragraph("ID", s['th']), Paragraph("En tant que", s['th']), Paragraph("Je veux...", s['th']), Paragraph("Afin de...", s['th']), Paragraph("Critères d'Acceptation (Gherkin)", s['th'])],
        [
            Paragraph("<b>US-01</b>", s['td']),
            Paragraph("Touriste", s['td']),
            Paragraph("Consulter le catalogue des sites patrimoniaux", s['td']),
            Paragraph("Accéder aux informations détaillées même hors-ligne.", s['td']),
            Paragraph("<b>Étant donné</b> l'application lancée avec ou sans réseau, <b>Quand</b> je parcours l'accueil, <b>Alors</b> les 5 sites s'affichent avec leur distance calculée.", s['td'])
        ],
        [
            Paragraph("<b>US-02</b>", s['td']),
            Paragraph("Touriste", s['td']),
            Paragraph("Ajouter ou retirer un site de mes favoris", s['td']),
            Paragraph("Conserver une sélection personnalisée pour mon séjour.", s['td']),
            Paragraph("<b>Étant donné</b> la fiche d'un site ouverte, <b>Quand</b> je clique sur le cœur, <b>Alors</b> le site est persisté localement sans doublon.", s['td'])
        ],
        [
            Paragraph("<b>US-03</b>", s['td']),
            Paragraph("Touriste", s['td']),
            Paragraph("Effectuer une réservation avec créneau horaire", s['td']),
            Paragraph("Planifier une visite pour un effectif défini (1 à 20 pers.).", s['td']),
            Paragraph("<b>Étant donné</b> le formulaire affiché, <b>Quand</b> je saisis des champs valides, <b>Alors</b> une réservation 'EN_ATTENTE' est créée avec référence unique.", s['td'])
        ],
        [
            Paragraph("<b>US-04</b>", s['td']),
            Paragraph("Touriste", s['td']),
            Paragraph("Régler ma réservation par Wave ou Orange Money", s['td']),
            Paragraph("Payer instantanément et obtenir un billet confirmé.", s['td']),
            Paragraph("<b>Étant donné</b> une réservation en attente, <b>Quand</b> le paiement mobile est validé, <b>Alors</b> le statut devient 'CONFIRMEE' et le billet QR est actif.", s['td'])
        ],
        [
            Paragraph("<b>US-05</b>", s['td']),
            Paragraph("Touriste", s['td']),
            Paragraph("Partager mon billet numérique sécurisé", s['td']),
            Paragraph("Transmettre les détails de la visite à mes proches.", s['td']),
            Paragraph("<b>Étant donné</b> mon billet affiché, <b>Quand</b> je clique sur 'Partager', <b>Alors</b> la feuille de partage native du téléphone s'ouvre avec le texte complet.", s['td'])
        ],
        [
            Paragraph("<b>US-06</b>", s['td']),
            Paragraph("Guide", s['td']),
            Paragraph("Accéder à l'Espace Guide via code PIN secret", s['td']),
            Paragraph("Consulter les arrivées et contrôler les entrées.", s['td']),
            Paragraph("<b>Étant donné</b> l'onglet réservations ouvert, <b>Quand</b> je saisis le code '2026', <b>Alors</b> le tableau de bord du guide se déverrouille.", s['td'])
        ],
        [
            Paragraph("<b>US-07</b>", s['td']),
            Paragraph("Guide", s['td']),
            Paragraph("Valider un billet par scan de QR Code", s['td']),
            Paragraph("Contrôler l'accès des visiteurs à l'entrée du site.", s['td']),
            Paragraph("<b>Étant donné</b> un QR Code scanné valide, <b>Quand</b> la réservation est confirmée, <b>Alors</b> le statut passe à 'EFFECTUEE' avec horodatage d'audit.", s['td'])
        ],
        [
            Paragraph("<b>US-08</b>", s['td']),
            Paragraph("Guide", s['td']),
            Paragraph("Encaisser un paiement en espèces sur place", s['td']),
            Paragraph("Régulariser un touriste ayant choisi l'option guichet.", s['td']),
            Paragraph("<b>Étant donné</b> un billet avec paiement sur place, <b>Quand</b> je valide l'entrée, <b>Alors</b> la caisse est incrémentée et le billet est clôturé.", s['td'])
        ],
    ], colWidths=[14*mm, 18*mm, 38*mm, 35*mm, 65*mm])
    t_us.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_us)
    story.append(Spacer(1, 8))

    story.append(Paragraph("2.3 Spécification détaillée des besoins fonctionnels", s['h2']))
    story.append(Paragraph("Les exigences fonctionnelles issues des User Stories ont été structurées en six modules applicatifs majeurs :", s['body']))
    story.append(Paragraph("• <b>Module F1 : Catalogue & Découverte Patrimoniale</b> : Présentation multimédia des cinq sites majeurs (Île de Carabane, Cases à Impluvium d'Enampore/Mlomp, Mémorial Le Joola, Cathédrale Saint-Antoine de Padoue, Réserve de Djilapao). Calcul géodésique de la distance en kilomètres par rapport à la position GPS de l'utilisateur. Filtrage multicritère (Catégorie, Localisation, Recherche textuelle).", s['bullet']))
    story.append(Paragraph("• <b>Module F2 : Gestion des Favoris Hors-Ligne</b> : Sauvegarde asynchrone des sites coups de cœur dans le stockage local SharedPreferences. Consultation instantanée sans connexion Internet, prévention stricte des doublons et isolation étanche du cache par adresse email.", s['bullet']))
    story.append(Paragraph("• <b>Module F3 : Tunnel de Réservation & Contrôles d'Intégrité</b> : Formulaire réactif FormState validant obligatoirement le nom, le prénom, le numéro de téléphone sénégalais (9 chiffres), la date (interdiction des dates passées), le créneau horaire et le nombre de personnes (borne stricte de 1 à 20). Recalcul automatique du montant total.", s['bullet']))
    story.append(Paragraph("• <b>Module F4 : Système de Paiement Hybride</b> : Prise en charge de trois modalités : simulation des passerelles de paiement mobile Wave et Orange Money (passage direct au statut CONFIRMEE avec génération de reçu transactionnel) et option de règlement en espèces sur place au guichet le jour de la visite.", s['bullet']))
    story.append(Paragraph("• <b>Module F5 : Billetterie Électronique & Sécurité QR Code</b> : Émission dynamique d'un billet officiel comportant la référence unique (ex: ZIG-2026-XXXX), le formatage de la date en français clair, l'effectif, le lieu et un QR Code matriciel encodant la clé de validation. Intégration du partage natif et navigation directe vers 'Mes Réservations'.", s['bullet']))
    story.append(Paragraph("• <b>Module F6 : Espace Guide & Réconciliation Financière</b> : Interface dédiée aux guides accrédités sécurisée par code PIN '2026'. Tableau de bord interactif affichant le planning des visites, les statistiques du jour, le moteur de scan QR avec contrôle anti-rejeu et l'audit de caisse des espèces perçues sur site.", s['bullet']))

    story.append(Paragraph("2.4 Spécification des besoins non fonctionnels", s['h2']))
    story.append(Paragraph("Les besoins non fonctionnels qualifient la qualité de service et la robustesse du système conformément aux normes de Génie Logiciel :", s['body']))
    story.append(Paragraph("• <b>Ergonomie & Usabilité (Material Design 3)</b> : Palette de couleurs inspirée des teintes naturelles de Casamance et de la charte de l'UASZ. Contrastes de texte conformes aux critères WCAG 2.1 niveau AA garantissant une lisibilité optimale en plein soleil.", s['bullet']))
    story.append(Paragraph("• <b>Résilience & Continuité de Service (Offline-First)</b> : L'utilisateur peut explorer le catalogue, gérer ses favoris et afficher ses billets numériques sans aucune connexion cellulaire. La synchronisation avec le cloud s'opère en tâche de fond dès le retour du réseau.", s['bullet']))
    story.append(Paragraph("• <b>Sécurité & Confidentialité</b> : Chiffrement des communications HTTP via TLS/SSL, hachage des mots de passe avec BCrypt et cloisonnement étanche des réservations et favoris par adresse email sur le terminal partagé.", s['bullet']))
    story.append(Paragraph("• <b>Performance & Légèreté</b> : Temps de réponse des endpoints REST inférieur à 200 ms sous charge nominale, temps de démarrage à froid de l'application inférieur à 2 secondes et bundle applicatif optimisé pour occuper moins de 35 Mo.", s['bullet']))

    story.append(Paragraph("2.5 Modélisation UML de l'analyse", s['h2']))
    story.append(Paragraph("Afin de formaliser avec rigueur la structure et le comportement dynamique du système, nous avons élaboré un ensemble de diagrammes UML d'analyse :", s['body']))

    story.append(Paragraph("<b>Figure 2.1 : Diagramme UML global des Cas d'Utilisation du système</b>", s['h3']))
    t_uc = Table([[
        Paragraph(
            "<b>┌─────────────────────────────────────────────────────────────────────────────┐</b><br/>"
            "<b>│                 SYSTÈME DE RÉSERVATION TOURISTIQUE (CASAMANCE)               │</b><br/>"
            "<b>├─────────────────────────────────────────────────────────────────────────────┤</b><br/>"
            "&nbsp;&nbsp;<b>[ TOURISTE ]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Consulter le catalogue patrimonial) &lt;--&lt;&lt;include&gt;&gt;-- (Calculer distance Haversine)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Gérer les favoris hors-ligne)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Effectuer une réservation) &lt;--&lt;&lt;include&gt;&gt;-- (Valider saisie FormState)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;--&lt;&lt;extend&gt;&gt;--- (Régler par Wave / OM / Guichet)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└───&gt; (Consulter et Partager son billet QR Code)<br/>"
            "<br/>"
            "&nbsp;&nbsp;<b>[ GUIDE TOURISTIQUE ]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Déverrouiller l'Espace Guide par code PIN '2026')<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Consulter le planning journalier des arrivées)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├───&gt; (Valider un billet par scan QR Code) &lt;--&lt;&lt;extend&gt;&gt;-- (Encaisser espèces guichet)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└───&gt; (Consulter l'audit de caisse et les statistiques du jour)<br/>"
            "<br/>"
            "&nbsp;&nbsp;<b>[ ADMINISTRATEUR ]</b> ───&gt; (Superviser l'annuaire, les données patrimoniales et les flux API)<br/>"
            "<b>└─────────────────────────────────────────────────────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_uc.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_uc)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Figure 2.2 : Diagramme de Séquence Système — Parcours de Réservation et Paiement Mobile</b>", s['h3']))
    t_seq = Table([[
        Paragraph(
            "<b>Touriste                 Interface Flutter (Form)     ReservationService         API Backend Spring Boot / MySQL</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 1. Renseigne formulaire ────&gt;│                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 2. Clique sur 'Réserver' ───&gt;├── 3. validate() [FormState] │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │── 4. save(reservation) ──&gt;│                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           ├── 5. POST /api/reservations ──────&gt;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │                                    ├── 6. INSERT (EN_ATTENTE)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │&lt;── 7. HTTP 200 (Reservation JSON) ─┤<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           ├── 8. Met en cache local ──────────┐│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │      (SharedPreferences)          ││<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │&lt;──────────────────────────────────┘│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │&lt;── 9. Réservation créée ──┤                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 10. Sélectionne Wave/OM ────&gt;│                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 11. Valide paiement ────────&gt;├── 12. updateStatut() ────&gt;│                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │   ('CONFIRMEE')           ├── 13. PATCH /reservations/statut ─&gt;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │                                    ├── 14. UPDATE statut<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │&lt;── 15. Confirmation HTTP 200 ──────┤<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│&lt;── 16. Affiche Billet QR ──────┤                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│   (Référence, Date FR, QR)    │                           │                                    │",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_seq.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_seq)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Figure 2.3 : Diagramme de Séquence Système — Contrôle d'accès et scan QR par le Guide Officiel</b>", s['h3']))
    t_seq_guide = Table([[
        Paragraph(
            "<b>Guide Officiel           GuideDashboardScreen         ReservationService         API Backend Spring Boot / MySQL</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 1. Saisit PIN '2026' ───────&gt;├── 2. Déverrouille vue     │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 3. Scanne QR du touriste ───&gt;├── 4. Décode payload QR    │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │   ('CASAMANCE-VISIT|ref') │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │── 5. trouverParReference()&gt;│                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           ├── 6. GET /reservations/code/{ref} ─&gt;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │&lt;── 7. Données de réservation ──────┤<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │&lt;── 8. Objet Réservation ──┤                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                ├── 9. Contrôle anti-rejeu  │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │   (Non annulée / non usée)│                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├── 10. Valide l'accès ─────────&gt;├── 11. Clôture visite     │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│   (Encaissement espèces ok)    │   (Statut 'EFFECTUEE')    ├── 12. PATCH /reservations/statut ─&gt;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │   (statut=EFFECTUEE, guide=2026)   ├── 13. UPDATE audit<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│                                │                           │&lt;── 14. Succès persistance ─────────┤<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│&lt;── 15. Alerte verte 'Billet' ──┤                           │                                    │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│   validé avec succès (+1)     │                           │                                    │",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_seq_guide.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_seq_guide)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Figure 2.4 : Diagramme d'États-Transitions du cycle de vie d'une réservation</b>", s['h3']))
    t_state = Table([[
        Paragraph(
            "&nbsp;&nbsp;&nbsp;&nbsp;<b>[*]</b> ──(Formulaire soumis avec succès)──&gt; <b>[ EN_ATTENTE ]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;┌───────────────────────────────────┼──────────────────────────────────┐<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│ (Paiement Wave/OM confirmé)       │ (Choix espèces guichet)          │ (Annulation touriste)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;▼                                   ▼                                  ▼<br/>"
            "&nbsp;&nbsp;<b>[ CONFIRMEE ]</b>                         <b>[ EN_ATTENTE (SUR_PLACE) ]</b>            <b>[ ANNULEE ]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;• Billet QR émis et actif             • Réservation planifiée              • Billet invalidé<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;• Partage possible                    • Paiement dû au guichet             • Créneau libéré<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│                                   │                                  │<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─────────────────┬─────────────────┘                                  ▼<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│ (Scan QR valide par guide accrédité)                  <b>[*]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;▼<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>[ EFFECTUEE ]</b><br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Visite clôturée et consommée<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Guide valideur audité (PIN 2026)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Caisse guichet incrémentée si espèces<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Tentative de second scan =&gt; ALERTE REJEU<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;▼<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>[*]</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_state.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_state)
    story.append(Spacer(1, 8))

    story.append(Paragraph("2.6 Contraintes opérationnelles et sécuritaires du système", s['h2']))
    story.append(Paragraph("Le système est assujetti à quatre contraintes d'ingénierie formelles :", s['body']))
    story.append(Paragraph("1. <b>Contrainte de performance</b> : Le démarrage à froid de l'application s'exécute en moins de 2 secondes. L'affichage d'une fiche patrimoniale et le calcul géodésique s'exécutent en moins de 50 ms.", s['bullet']))
    story.append(Paragraph("2. <b>Contrainte anti-rejeu et infalsifiabilité</b> : Le code QR du billet ne peut être validé qu'une seule et unique fois. Dès sa consommation, tout scan ultérieur déclenche immédiatement une alerte 'Billet déjà utilisé', empêchant toute fraude par duplication de capture d'écran.", s['bullet']))
    story.append(Paragraph("3. <b>Contrainte de conformité et confidentialité</b> : Les données d'identité collectées (nom, téléphone) se limitent strictement aux exigences de sécurité du guidage et ne font l'objet d'aucun traçage commercial tiers.", s['bullet']))
    story.append(Paragraph("4. <b>Contrainte de portabilité native</b> : Le code source Flutter s'exécute de façon strictement identique sur smartphone Android (APK natif) et sur navigateur Web (WebAssembly / HTML5 Canvas).", s['bullet']))
    story.append(PageBreak())

    # =========================================================================
    # CHAPITRE 3 : CONCEPTION DU SYSTÈME (GÉNIE LOGICIEL)
    # =========================================================================
    story.append(Paragraph("CHAPITRE 3 : CONCEPTION DU SYSTÈME (GÉNIE LOGICIEL)", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("3.1 Architecture logicielle globale 3-Tiers", s['h2']))
    story.append(Paragraph(
        "Conformément aux principes directeurs du Génie Logiciel, notre système adopte une architecture 3-Tiers (ou architecture en couches découplées). "
        "Ce modèle garantit une séparation stricte des préoccupations (Separation of Concerns), améliore la testabilité unitaire et permet de faire évoluer "
        "indépendamment l'interface utilisateur, la logique métier et la couche de persistance relationnelle.",
        s['body']
    ))

    story.append(Paragraph("<b>Figure 3.1 : Architecture logicielle globale 3-Tiers orientée services</b>", s['h3']))
    t_arch = Table([[
        Paragraph(
            "<b>┌─────────────────────────────────────────────────────────────────────────────┐</b><br/>"
            "<b>│                     COUCHE PRÉSENTATION (FLUTTER DART)                      │</b><br/>"
            "│  [HomeScreen]  [BookingFormScreen]  [TicketQrScreen]  [GuideDashboardScreen]│<br/>"
            "│  ─────────────  ───────────────────  ────────────────  ───────────────────── │<br/>"
            "│  Gestion d'État Réactive • Cache SharedPreferences • Validation FormState    │<br/>"
            "<b>└──────────────────────────────────────┬──────────────────────────────────────┘</b><br/>"
            "                                       │ Requêtes HTTPS / REST JSON<br/>"
            "                                       ▼ (Port 443 sécurisé SSL)<br/>"
            "<b>┌─────────────────────────────────────────────────────────────────────────────┐</b><br/>"
            "<b>│                 COUCHE MÉTIER & APPLICATION (SPRING BOOT 3 / JAVA 21)       │</b><br/>"
            "│  [ReservationController]  [PatrimoineController]  [AuthMobileController]   │<br/>"
            "│  ───────────────────────  ──────────────────────  ────────────────────   │<br/>"
            "│  Services Métiers • Mappers DTO • Logique de Validation & Audit • Sécurité  │<br/>"
            "<b>└──────────────────────────────────────┬──────────────────────────────────────┘</b><br/>"
            "                                       │ Protocole JDBC over TLS/SSL<br/>"
            "                                       ▼ (Port managé Aiven 26463)<br/>"
            "<b>┌─────────────────────────────────────────────────────────────────────────────┐</b><br/>"
            "<b>│               COUCHE PERSISTENCE & DONNÉES (MYSQL 8 CLOUD AIVEN)            │</b><br/>"
            "│  Tables relationnelles : 'patrimoines', 'reservations_mobile', 'comptes',   │<br/>"
            "│  'avis_mobile', 'utilisateurs' • Intégrité Référentielle ACID • Index B-Tree│<br/>"
            "<b>└─────────────────────────────────────────────────────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_arch.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_arch)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.2 Diagramme de composants du système distribué", s['h2']))
    story.append(Paragraph(
        "Le diagramme de composants illustre le découplage fonctionnel entre les modules du client Flutter et les composants "
        "du microservice backend Spring Boot 3 :",
        s['body']
    ))

    story.append(Paragraph("<b>Figure 3.2 : Diagramme de composants du système distribué</b>", s['h3']))
    t_comp = Table([[
        Paragraph(
            "<b>┌────────────────────────────────────┐      ┌───────────────────────────────────┐</b><br/>"
            "<b>│     COMPOSANTS CLIENT (FLUTTER)    │      │    COMPOSANTS BACKEND (SPRING)    │</b><br/>"
            "│                                    │      │                                   │<br/>"
            "│  ┌──────────────────────────────┐  │      │  ┌─────────────────────────────┐  │<br/>"
            "│  │     &lt;&lt;Component UI&gt;&gt;         │  │      │  │     &lt;&lt;Component REST&gt;&gt;      │  │<br/>"
            "│  │   Screens & Formulaires      │  │      │  │  ReservationMobileController│  │<br/>"
            "│  └──────────────┬───────────────┘  │      │  └──────────────┬──────────────┘  │<br/>"
            "│                 │                  │      │                 │                 │<br/>"
            "│  ┌──────────────▼───────────────┐  │      │  ┌──────────────▼─────────────┐  │<br/>"
            "│  │    &lt;&lt;Component Service&gt;&gt;     │  │ HTTPS│  │    &lt;&lt;Component Service&gt;&gt;    │  │<br/>"
            "│  │      ReservationService      ├──┼─────&gt;│  │    PatrimoineServiceImpl    │  │<br/>"
            "│  └──────────────┬───────────────┘  │ JSON │  └──────────────┬─────────────┘  │<br/>"
            "│                 │                  │      │                 │                 │<br/>"
            "│  ┌──────────────▼───────────────┐  │      │  ┌──────────────▼─────────────┐  │<br/>"
            "│  │     &lt;&lt;Component Cache&gt;&gt;      │  │      │  │      &lt;&lt;Component DAO&gt;&gt;      │  │<br/>"
            "│  │      SharedPreferences       │  │      │  │ ReservationMobileRepository│  │<br/>"
            "│  └──────────────────────────────┘  │      │  └──────────────┬─────────────┘  │<br/>"
            "<b>└────────────────────────────────────┘      └─────────────────┼─────────────────┘</b><br/>"
            "                                                              │ JDBC over SSL<br/>"
            "                                                              ▼<br/>"
            "                                                <b>┌─────────────────────────────┐</b><br/>"
            "                                                <b>│   &lt;&lt;Base MySQL 8 Aiven&gt;&gt;    │</b><br/>"
            "                                                <b>└─────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_comp.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_comp)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Tableau 3.1 : Spécification formelle des contrats d'interface (Endpoints REST) :</b>", s['h3']))
    t_api = Table([
        [Paragraph("Méthode", s['th']), Paragraph("URI / Route REST", s['th']), Paragraph("Accès", s['th']), Paragraph("Description Métier & Réponse JSON", s['th'])],
        [Paragraph("<b>GET</b>", s['td']), Paragraph("/api/patrimoines", s['td']), Paragraph("Public", s['td']), Paragraph("Retourne la liste des sites touristiques avec coordonnées GPS, descriptions et tarifs officiels.", s['td'])],
        [Paragraph("<b>POST</b>", s['td']), Paragraph("/api/reservations", s['td']), Paragraph("Touriste", s['td']), Paragraph("Crée une réservation avec statut initial 'EN_ATTENTE' et génère la référence unique (ZIG-...).", s['td'])],
        [Paragraph("<b>GET</b>", s['td']), Paragraph("/api/reservations", s['td']), Paragraph("Guide/Touriste", s['td']), Paragraph("Retourne l'ensemble des réservations pour le planning guide et l'historique utilisateur.", s['td'])],
        [Paragraph("<b>GET</b>", s['td']), Paragraph("/api/reservations/code/{code}", s['td']), Paragraph("Guide", s['td']), Paragraph("Recherche instantanée d'un billet par sa référence pour la validation de scan QR Code.", s['td'])],
        [Paragraph("<b>PATCH</b>", s['td']), Paragraph("/api/reservations/{code}/statut", s['td']), Paragraph("Guide/Touriste", s['td']), Paragraph("Met à jour le statut (CONFIRMEE, EFFECTUEE, ANNULEE) et consigne le guide valideur dans l'audit.", s['td'])],
        [Paragraph("<b>POST</b>", s['td']), Paragraph("/api/auth/login", s['td']), Paragraph("Public", s['td']), Paragraph("Authentifie un usager (vérification du mot de passe haché BCrypt) et retourne le profil complet.", s['td'])],
    ], colWidths=[20*mm, 52*mm, 24*mm, 74*mm])
    t_api.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_api)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.3 Diagramme de packages et organisation modulaire", s['h2']))
    story.append(Paragraph("La structure des répertoires respecte strictement la modularité et la séparation des responsabilités :", s['body']))

    story.append(Paragraph("<b>Figure 3.3 : Diagramme de packages Flutter et Spring Boot</b>", s['h3']))
    t_pack = Table([[
        Paragraph(
            "<b>PACKAGES CLIENT (FLUTTER)                       PACKAGES SERVEUR (SPRING BOOT 3)</b><br/>"
            "lib/                                            backend/src/main/java/sn/zig/patrimoine/<br/>"
            "├── core/                                       ├── controller/<br/>"
            "│   ├── config/ (ApiConfig.dart)                 │   ├── PatrimoineController.java<br/>"
            "│   ├── models/ (Patrimoine, Reservation, User)  │   ├── ReservationMobileController.java<br/>"
            "│   ├── theme/  (AppTheme.dart)                  │   └── AuthMobileController.java<br/>"
            "│   └── widgets/(CasamanceStatusBadge.dart)     ├── service/<br/>"
            "├── features_colle/                              │   └── impl/ (PatrimoineServiceImpl.java)<br/>"
            "│   ├── auth/    (LoginScreen, AuthService)      ├── repository/<br/>"
            "│   ├── catalogue/(HomeScreen, SitesListScreen) │   ├── PatrimoineRepository.java<br/>"
            "│   └── map/     (MapExploreScreen)              │   └── ReservationMobileRepository.java<br/>"
            "├── features_thiamba/                            ├── model/<br/>"
            "│   ├── reservation/ (BookingFormScreen)         │   ├── Patrimoine.java<br/>"
            "│   ├── ticketing/   (TicketQrScreen)            │   ├── ReservationMobile.java<br/>"
            "│   ├── guide/       (GuideDashboardScreen)      │   └── UtilisateurBdd.java<br/>"
            "│   └── services/    (ReservationService.dart)   └── MsDataInitializer.java (Seeding DB)",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_pack.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_pack)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.4 Diagramme de déploiement physique et cloud", s['h2']))
    story.append(Paragraph("La topologie d'hébergement met en œuvre une architecture cloud distribuée moderne entièrement automatisée :", s['body']))

    story.append(Paragraph("<b>Figure 3.4 : Diagramme de déploiement Cloud (Docker sur Render & MySQL sur Aiven)</b>", s['h3']))
    t_deploy = Table([[
        Paragraph(
            "<b>┌────────────────────────┐      HTTPS / TLS       ┌─────────────────────────────────────────┐</b><br/>"
            "<b>│   TERMINAUX CLIENTS    │ ──────────────────────&gt;│         PLATEFORME CLOUD RENDER         │</b><br/>"
            "│                        │    (Port 443 public)   │                                         │<br/>"
            "│  • Smartphone Android  │                        │  ┌───────────────────────────────────┐  │<br/>"
            "│    (PWA ou APK natif)  │                        │  │ Conteneur Docker Frontend         │  │<br/>"
            "│                        │                        │  │ (Flutter Web + Serveur Nginx)     │  │<br/>"
            "│  • Navigateur Desktop  │                        │  └─────────────────┬─────────────────┘  │<br/>"
            "│    (Chrome, Safari)    │                        │                    │ Reverse-Proxy /api │<br/>"
            "<b>└────────────────────────┘</b>                        │                    ▼ (proxy_ssl_name on)│<br/>"
            "                                                  │  ┌───────────────────────────────────┐  │<br/>"
            "                                                  │  │ Conteneur Docker Backend          │  │<br/>"
            "                                                  │  │ (Spring Boot 3 / Java 21 OpenJDK) │  │<br/>"
            "                                                  │  └─────────────────┬─────────────────┘  │<br/>"
            "                                                  <b>└────────────────────┼────────────────────┘</b><br/>"
            "                                                                       │ JDBC over TLS/SSL<br/>"
            "                                                                       ▼ (Port sécurisé 26463)<br/>"
            "                                                  <b>┌─────────────────────────────────────────┐</b><br/>"
            "                                                  <b>│         PLATEFORME CLOUD AIVEN          │</b><br/>"
            "                                                  │  • Instance Managée MySQL 8.0           │<br/>"
            "                                                  │  • Stockage répliqué, chiffré au repos  │<br/>"
            "                                                  │  • Certificat SSL obligatoire (CA Aiven)│<br/>"
            "                                                  <b>└─────────────────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_deploy.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_deploy)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.5 Diagramme de classes métier orienté objet", s['h2']))
    story.append(Paragraph("Le modèle conceptuel de données traduit les entités du domaine sous forme de classes fortement typées :", s['body']))

    story.append(Paragraph("<b>Figure 3.5 : Diagramme de classes métier orienté objet</b>", s['h3']))
    t_class = Table([[
        Paragraph(
            "<b>┌─────────────────────────────────┐                 ┌────────────────────────────────────┐</b><br/>"
            "<b>│           Patrimoine            │                 │         ReservationMobile          │</b><br/>"
            "<b>├─────────────────────────────────┤                 ├────────────────────────────────────┤</b><br/>"
            "│ - id: Long                      │ 1             * │ - id: Long                         │<br/>"
            "│ - nomPatrimoine: String         │&lt;────────────────┤ - codeReservation: String (Unique) │<br/>"
            "│ - codePatrimoine: String        │                 │ - nomTouriste: String              │<br/>"
            "│ - descriptionPatrimoine: String │                 │ - telephoneTouriste: String        │<br/>"
            "│ - adressePatrimoine: String     │                 │ - emailTouriste: String            │<br/>"
            "│ - latitudePatrimoine: Double    │                 │ - dateVisite: String               │<br/>"
            "│ - longitudePatrimoine: Double   │                 │ - creneauHoraire: String           │<br/>"
            "│ - capacitePatrimoine: Integer   │                 │ - nombrePersonnes: Integer         │<br/>"
            "<b>├─────────────────────────────────┤</b>                 │ - montantTotal: Double             │<br/>"
            "│ + getDistance(lat, lon): double │                 │ - modePaiement: String             │<br/>"
            "│ + isFavori(email): boolean      │                 │ - statut: String                   │<br/>"
            "<b>└─────────────────────────────────┘</b>                 │ - nomGuideValideur: String         │<br/>"
            "                                                    <b>├────────────────────────────────────┤</b><br/>"
            "                                                    │ + estValidePourScan(): boolean     │<br/>"
            "                                                    │ + cloturerVisite(nomGuide): void   │<br/>"
            "                                                    <b>└────────────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_class.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_class)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.6 Diagramme d'objets (instanciation à l'exécution)", s['h2']))
    story.append(Paragraph("Le diagramme d'objets fige l'état de la mémoire lors d'un scénario réel : la validation sur site d'une visite à l'Île de Carabane :", s['body']))

    story.append(Paragraph("<b>Figure 3.6 : Diagramme d'objets instanciés lors de la validation d'une visite</b>", s['h3']))
    t_obj = Table([[
        Paragraph(
            "<b>┌────────────────────────────────────────┐       ┌────────────────────────────────────────┐</b><br/>"
            "<b>│          carabane : Patrimoine         │       │        res_042 : Reservation           │</b><br/>"
            "<b>├────────────────────────────────────────┤       ├────────────────────────────────────────┤</b><br/>"
            "│ id = 4                                 │       │ id = 42                                │<br/>"
            "│ nomPatrimoine = 'Île de Carabane'      │       │ codeReservation = 'ZIG-2026-9814'      │<br/>"
            "│ codePatrimoine = 'PAT-CAR-004'         │       │ nomTouriste = 'Aïssatou Fall'          │<br/>"
            "│ latitude = 12.5567                     │       │ dateVisite = '19 novembre 2026'        │<br/>"
            "│ longitude = -16.7025                   │       │ nombrePersonnes = 3                    │<br/>"
            "│ capacite = 300                         │       │ montantTotal = 9000.0 FCFA             │<br/>"
            "<b>└────────────────────────────────────────┘</b>       │ modePaiement = 'WAVE'                  │<br/>"
            "                                                 │ statut = 'EFFECTUEE'                   │<br/>"
            "                                                 │ nomGuideValideur = 'Guide Officiel'    │<br/>"
            "                                                 <b>└────────────────────────────────────────┘</b>",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_obj.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_obj)
    story.append(Spacer(1, 8))

    story.append(Paragraph("3.7 Design Patterns et patrons d'architecture appliqués", s['h2']))
    story.append(Paragraph("Pour garantir l'extensibilité, la robustesse et la propreté du code, six patrons de conception ont été mobilisés :", s['body']))
    story.append(Paragraph("• <b>Singleton Pattern</b> : Garantit une instance unique partagée pour les services critiques (ReservationService, FavoritesService, AuthService), centralisant l'état et évitant les allocations multiples.", s['bullet']))
    story.append(Paragraph("• <b>Observer / Reactive State Pattern</b> : Gestion d'état réactive via ValueNotifier et setState, notifiant automatiquement les widgets abonnés lors des changements (incrémentation du compteur du guide, ajout d'un favori) sans rechargement global.", s['bullet']))
    story.append(Paragraph("• <b>Data Transfer Object (DTO)</b> : Découplage strict entre les entités JPA de la base MySQL et les données transmises sur le réseau, allégeant la charge utile JSON et renforçant la sécurité applicative.", s['bullet']))
    story.append(Paragraph("• <b>Repository Pattern</b> : Encapsulation des opérations de persistance dans des interfaces Spring Data JPA héritant de JpaRepository, évitant tout couplage avec le dialecte SQL brut.", s['bullet']))
    story.append(Paragraph("• <b>Dependency Injection (Inversion de Contrôle - IoC)</b> : Injection native des dépendances gérée par le conteneur Spring Boot (@RequiredArgsConstructor), assurant un découplage total et facilitant la création de mocks pour les tests.", s['bullet']))
    story.append(Paragraph("• <b>Factory Method Pattern</b> : Délégation de l'instanciation des objets métiers aux méthodes usines fromJson() et toJson() en Dart, garantissant une désérialisation typée et sécurisée.", s['bullet']))
    story.append(PageBreak())

    # =========================================================================
    # CHAPITRE 4 : IMPLÉMENTATION ET TESTS FONCTIONNELS
    # =========================================================================
    story.append(Paragraph("CHAPITRE 4 : IMPLÉMENTATION ET TESTS FONCTIONNELS", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("4.1 Environnement et pile technologique de réalisation", s['h2']))
    story.append(Paragraph("L'implémentation de la solution a mobilisé une suite d'outils professionnels et de bibliothèques logicielles certifiées :", s['body']))

    t_tools = Table([
        [Paragraph("Couche Applicative", s['th']), Paragraph("Outil / Dépendance", s['th']), Paragraph("Version", s['th']), Paragraph("Rôle et Justification dans le Projet", s['th'])],
        [Paragraph("Client Mobile & Web", s['td']), Paragraph("Flutter SDK / Dart", s['td']), Paragraph("3.47 / 3.13", s['td']), Paragraph("Compilateur natif AOT multiplateforme avec null-safety intégrale.", s['td'])],
        [Paragraph("Rendu QR Code", s['td']), Paragraph("qr_flutter", s['td']), Paragraph("^4.1.0", s['td']), Paragraph("Génération vectorielle de QR codes haute densité avec correction d'erreur niveau H.", s['td'])],
        [Paragraph("Persistance Locale", s['td']), Paragraph("shared_preferences", s['td']), Paragraph("^2.5.4", s['td']), Paragraph("Stockage asynchrone clé-valeur pour la résilience hors-ligne sur terminal.", s['td'])],
        [Paragraph("Partage Système", s['td']), Paragraph("share_plus", s['td']), Paragraph("^10.1.4", s['td']), Paragraph("Invocation des boîtes de dialogue natives de partage de billets (WhatsApp, SMS).", s['td'])],
        [Paragraph("Serveur Backend", s['td']), Paragraph("Spring Boot 3", s['td']), Paragraph("3.2.5", s['td']), Paragraph("Framework Java 21 OpenJDK haute performance avec Spring Data JPA et validation.", s['td'])],
        [Paragraph("SGBD Managé", s['td']), Paragraph("MySQL Community", s['td']), Paragraph("8.0", s['td']), Paragraph("Cluster managé sur Aiven avec chiffrement TLS obligatoire et conformité ACID.", s['td'])],
        [Paragraph("Conteneurisation", s['td']), Paragraph("Docker & Nginx", s['td']), Paragraph("1.31 Alpine", s['td']), Paragraph("Images légères multi-stage déployées en continu sur la plateforme Render.", s['td'])],
    ], colWidths=[32*mm, 34*mm, 20*mm, 84*mm])
    t_tools.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_tools)
    story.append(Spacer(1, 8))

    story.append(Paragraph("4.2 Développement de la solution et modules applicatifs clés", s['h2']))
    story.append(Paragraph("L'application se distingue par une organisation fluide et claire des parcours utilisateurs :", s['body']))
    story.append(Paragraph("1. <b>Catalogue immersif des joyaux de Casamance</b> : Présente les cinq sites sous forme de fiches enrichies affichant la dénomination, le résumé culturel, le tarif adulte officiel et la distance kilométrique calculée en temps réel par rapport à la position GPS de l'usager.", s['body']))
    story.append(Paragraph("2. <b>Formulaire de réservation réactif</b> : Conçu avec FormState et des validateurs stricts par expressions régulières (téléphone à 9 chiffres, nom non vide, effectif borné entre 1 et 20). Tout envoi non conforme est bloqué avec surlignage en rouge et message explicatif.", s['body']))
    story.append(Paragraph("3. <b>Écran du Billet Numérique (TicketQrScreen)</b> : Rendu élégant arborant les couleurs de l'UASZ, synthétisant le nom du site, la date en français (ex: '19 novembre 2026'), l'effectif, le lieu et un QR Code central scannable, avec boutons de partage et retour rapide.", s['body']))
    story.append(Paragraph("4. <b>Espace Guide et Contrôle d'Accès (GuideDashboardScreen)</b> : Déverrouillé par code PIN secret '2026'. Affiche le compteur de visites réalisées, le planning consolidé et le module de scan QR Code avec contrôle anti-rejeu et audit de caisse.", s['body']))

    story.append(Paragraph("4.3 Description approfondie des algorithmes essentiels", s['h2']))
    story.append(Paragraph("Le bon fonctionnement du système repose sur trois algorithmes clés conçus et implémentés au sein des services métiers :", s['body']))

    story.append(Paragraph("<b>Algorithme 1 : Calcul de distance géodésique par la formule de Haversine</b>", s['h3']))
    story.append(Paragraph(
        "Pour déterminer avec une précision métrique la distance orthodromique entre l'usager (lat1, lon1) et le site patrimonial (lat2, lon2) "
        "sur la surface sphérique de la Terre (rayon moyen R = 6371 km) :",
        s['body']
    ))

    t_a1 = Table([[
        Paragraph(
            "// Implémentation en Dart dans LocationService<br/>"
            "double calculerDistance(double lat1, double lon1, double lat2, double lon2) {<br/>"
            "  const double R = 6371.0; // Rayon moyen de la Terre en kilomètres<br/>"
            "  final double dLat = _degVersRad(lat2 - lat1);<br/>"
            "  final double dLon = _degVersRad(lon2 - lon1);<br/>"
            "  final double a = sin(dLat / 2) * sin(dLat / 2) +<br/>"
            "                   cos(_degVersRad(lat1)) * cos(_degVersRad(lat2)) *<br/>"
            "                   sin(dLon / 2) * sin(dLon / 2);<br/>"
            "  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));<br/>"
            "  return R * c; // Distance en kilomètres avec précision métrique<br/>"
            "}",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_a1.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_a1)
    story.append(Spacer(1, 6))

    story.append(Paragraph("<b>Algorithme 2 : Génération, signature et formatage du payload QR Code</b>", s['h3']))
    story.append(Paragraph(
        "Afin d'empêcher toute falsification du billet numérique, le QR Code encode un payload structuré et vérifiable :",
        s['body']
    ))

    t_a2 = Table([[
        Paragraph(
            "// Formatage standardisé du payload QR Code du billet dans TicketQrScreen<br/>"
            "String genererPayloadBillet(Reservation res) {<br/>"
            "  final String prefix = 'CASAMANCE-VISIT';<br/>"
            "  final String ref = res.codeReservation;     // Ex: ZIG-2026-9814<br/>"
            "  final int siteId = res.patrimoineId;         // Identifiant du monument<br/>"
            "  final int nbPers = res.nombrePersonnes;       // Nombre de places acquittées<br/>"
            "  final int timestamp = DateTime.now().millisecondsSinceEpoch;<br/>"
            "  return '$prefix|$ref|$siteId|$nbPers|$timestamp';<br/>"
            "}",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_a2.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_a2)
    story.append(Spacer(1, 6))

    story.append(Paragraph("<b>Algorithme 3 : Décodage, contrôle anti-rejeu et réconciliation financière</b>", s['h3']))
    story.append(Paragraph(
        "Lors de la présentation du billet, l'Espace Guide exécute une séquence de vérifications strictes :",
        s['body']
    ))

    t_a3 = Table([[
        Paragraph(
            "// Validation sécurisée et contrôle anti-rejeu dans GuideDashboardScreen<br/>"
            "Future&lt;ValidationResult&gt; validerBillet(String qrPayload, String nomGuide) async {<br/>"
            "  final List&lt;String&gt; parts = qrPayload.split('|');<br/>"
            "  if (parts.length &lt; 2 || parts[0] != 'CASAMANCE-VISIT') {<br/>"
            "    return ValidationResult(succes: false, message: 'Format de QR Code invalide.');<br/>"
            "  }<br/>"
            "  final String reference = parts[1];<br/>"
            "  final res = await _reservationService.trouverParReference(reference);<br/>"
            "  if (res == null) return ValidationResult(succes: false, message: 'Billet introuvable.');<br/>"
            "  if (res.statut == 'EFFECTUEE') return ValidationResult(succes: false, message: 'ALERTE : Billet DÉJÀ utilisé !');<br/>"
            "  if (res.statut == 'ANNULEE') return ValidationResult(succes: false, message: 'REFUS : Réservation ANNULÉE.');<br/>"
            "  <br/>"
            "  // Clôture avec attribution du guide valideur et confirmation caisse<br/>"
            "  await _reservationService.updateStatut(reference, 'EFFECTUEE', nomGuideValideur: nomGuide);<br/>"
            "  return ValidationResult(succes: true, message: 'Billet validé avec succès ! Entrée autorisée.');<br/>"
            "}",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_a3.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_a3)
    story.append(Spacer(1, 8))

    story.append(Paragraph("4.4 Gestion des exceptions et résilience réseau", s['h2']))
    story.append(Paragraph("L'expérience utilisateur en zone rurale dépend de la capacité de l'application à intercepter et gérer élégamment les erreurs :", s['body']))
    story.append(Paragraph("• <b>Interception des exceptions HTTP et timeouts</b> : Requêtes REST encapsulées dans des blocs try/catch typés interceptant SocketException et TimeoutException (seuil de 3 secondes). En cas d'indisponibilité du serveur distant, l'application bascule automatiquement et de manière transparente sur le cache SharedPreferences.", s['bullet']))
    story.append(Paragraph("• <b>Validation défensive côté client</b> : Contrôles préventifs immédiats sur les formulaires (TextEditingController et GlobalKey&lt;FormState&gt;) évitant toute transmission de données invalides vers le réseau.", s['bullet']))
    story.append(Paragraph("• <b>Gestion centralisée des erreurs serveur</b> : Gestion globale des erreurs avec @ControllerAdvice côté Spring Boot, renvoyant des codes HTTP standardisés et des charges utiles JSON explicites.", s['bullet']))

    story.append(Paragraph("4.5 Stratégie de tests et validation fonctionnelle (100 % de succès)", s['h2']))
    story.append(Paragraph("Pour apporter la preuve formelle de la fiabilité de l'application, nous avons élaboré une batterie de dix scénarios de tests couvrant l'intégralité des flux fonctionnels :", s['body']))

    t_test = Table([
        [Paragraph("ID", s['th']), Paragraph("Intitulé du Scénario", s['th']), Paragraph("Conditions Opératoires", s['th']), Paragraph("Résultat Attendu", s['th']), Paragraph("Statut", s['th'])],
        [Paragraph("<b>TEST-01</b>", s['td']), Paragraph("Chargement catalogue & Haversine", s['td']), Paragraph("Calcul GPS pour les 5 sites de Casamance", s['td']), Paragraph("Distances positives, précision kilométrique", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-02</b>", s['td']), Paragraph("Ajout et Retrait de Favoris", s['td']), Paragraph("Clic sur l'icône cœur d'un patrimoine", s['td']), Paragraph("Mise à jour réactive, aucun doublon", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-03</b>", s['td']), Paragraph("Persistance des favoris hors-ligne", s['td']), Paragraph("Arrêt complet de l'app, relance sans réseau", s['td']), Paragraph("Favoris intacts rechargés depuis le cache", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-04</b>", s['td']), Paragraph("Contrôle FormState réservation", s['td']), Paragraph("Envoi avec 0 participant ou date passée", s['td']), Paragraph("Blocage de l'envoi, messages en français", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-05</b>", s['td']), Paragraph("Réservation nominale complète", s['td']), Paragraph("Saisie de coordonnées valides", s['td']), Paragraph("Réservation créée, référence ZIG générée", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-06</b>", s['td']), Paragraph("Simulation paiement Wave / OM", s['td']), Paragraph("Saisie du numéro mobile de paiement", s['td']), Paragraph("Statut CONFIRMEE, reçu transactionnel émis", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-07</b>", s['td']), Paragraph("Génération du billet QR Code", s['td']), Paragraph("Ouverture de l'écran TicketQrScreen", s['td']), Paragraph("QR Code matriciel rendu avec date française", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-08</b>", s['td']), Paragraph("Partage système du billet", s['td']), Paragraph("Clic sur le bouton natif 'Partager'", s['td']), Paragraph("Feuille de partage ouverte (WhatsApp/SMS)", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-09</b>", s['td']), Paragraph("Scan et validation par le Guide", s['td']), Paragraph("Saisie PIN 2026, scan du billet QR", s['td']), Paragraph("Statut EFFECTUEE, visiteur comptabilisé", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
        [Paragraph("<b>TEST-10</b>", s['td']), Paragraph("Sécurité anti-rejeu et billet usé", s['td']), Paragraph("Tentative de second scan d'un billet validé", s['td']), Paragraph("Refus immédiat avec alerte 'Déjà utilisé'", s['td']), Paragraph("<b>100 % VALIDÉ</b>", s['td'])],
    ], colWidths=[15*mm, 38*mm, 45*mm, 47*mm, 25*mm])
    t_test.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), COLOR_PRIMARY),
        ('GRID', (0,0), (-1,-1), 0.5, COLOR_BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, COLOR_BG_LIGHT]),
    ]))
    story.append(t_test)
    story.append(PageBreak())

    # =========================================================================
    # CONCLUSION GÉNÉRALE ET PERSPECTIVES
    # =========================================================================
    story.append(Paragraph("CONCLUSION GÉNÉRALE ET PERSPECTIVES", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=10))

    story.append(Paragraph("1. Bilan général des réalisations", s['h2']))
    story.append(Paragraph(
        "Arrivées au terme de ce projet opérationnel marquant l'aboutissement de notre formation en Licence d'Ingénierie Informatique "
        "à l'Université Assane Seck de Ziguinchor, nous dressons un bilan éminemment positif de notre travail. Notre objectif initial, "
        "qui consistait à concevoir, modéliser, réaliser et déployer une plateforme logicielle complète de découverte et de réservation "
        "de visites touristiques en Casamance, a été intégralement atteint.",
        s['body']
    ))
    story.append(Paragraph(
        "En appliquant avec rigueur les méthodes du Génie Logiciel et la démarche Agile Scrum, notre binôme a livré un système distribué opérationnel "
        "articulé autour d'une application Flutter (Mobile & Web) réactive, d'un backend REST Spring Boot 3 sous Java 21, et d'une base relationnelle "
        "MySQL 8 managée dans le cloud Aiven. Les défis techniques majeurs — la continuité de service hors-ligne par SharedPreferences, la billetterie "
        "numérique sécurisée par QR Code infalsifiable, l'espace guide avec contrôle anti-rejeu et la réconciliation financière des encaissements en espèces — "
        "ont tous été résolus avec succès.",
        s['body']
    ))

    story.append(Paragraph("2. Difficultés rencontrées et solutions d'ingénierie apportées", s['h2']))
    story.append(Paragraph("La réalisation de ce projet a confronté notre binôme à des défis formateurs :", s['body']))
    story.append(Paragraph("• <b>La synchronisation de l'état asynchrone hors-ligne</b> : Concilier le stockage local SharedPreferences avec les requêtes distantes a nécessité la mise en œuvre d'un mécanisme de bascule automatique évitant tout blocage de l'interface en cas de coupure réseau 4G.", s['bullet']))
    story.append(Paragraph("• <b>La portabilité multiplateforme Flutter</b> : Adapter dynamiquement l'interface entre les smartphones Android et les navigateurs Web a nécessité des composants adaptatifs et une configuration minutieuse du reverse-proxy Nginx sous Docker (gestion des en-têtes SSL SNI et anti-cache).", s['bullet']))
    story.append(Paragraph("• <b>Le travail collaboratif et la fusion Git</b> : La gestion conjointe du dépôt distant a exigé une discipline stricte dans le découpage des tâches et l'application de rebase pour conserver un historique de commits linéaire et propre.", s['bullet']))

    story.append(Paragraph("3. Perspectives et évolutions futures", s['h2']))
    story.append(Paragraph("Bien que la solution actuelle soit pleinement exploitable en conditions réelles, plusieurs axes d'évolution prometteurs peuvent être envisagés :", s['body']))
    story.append(Paragraph("• <b>Passerelles de paiement réelles en production</b> : Interfacer directement les API marchandes officielles de Wave Sénégal et d'Orange Money via leurs SDK dès l'obtention des agréments bancaires.", s['bullet']))
    story.append(Paragraph("• <b>Audioguide multilingue patrimonial</b> : Enrichir la plateforme d'un système de guidage audio hors-ligne disponible en langues locales casamançaises (Diola, Mandingue, Wolof) et en langues internationales (Français, Anglais, Espagnol).", s['bullet']))
    story.append(Paragraph("• <b>Système de recommandation personnalisé par Intelligence Artificielle</b> : Intégrer un moteur de filtrage collaboratif proposant aux touristes des circuits thématiques sur mesure (éco-tourisme, artisanat, architecture) selon leurs centres d'intérêt.", s['bullet']))
    story.append(Spacer(1, 10))

    # =========================================================================
    # BIBLIOGRAPHIE ET WEBOGRAPHIE
    # =========================================================================
    story.append(Paragraph("BIBLIOGRAPHIE ET WEBOGRAPHIE", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=8))

    story.append(Paragraph("1. Ouvrages de référence en Génie Logiciel", s['h2']))
    story.append(Paragraph("• <b>Sommerville, I. (2016)</b>. <i>Software Engineering (10th Edition)</i>. Pearson Education. Ouvrage de référence mondial sur les processus agiles, l'ingénierie des exigences et l'architecture logicielle.", s['bullet']))
    story.append(Paragraph("• <b>Pressman, R. S. & Maxim, B. R. (2020)</b>. <i>Software Engineering: A Practitioner's Approach (9th Edition)</i>. McGraw-Hill. Traité sur la modélisation UML, les patrons de conception et la stratégie de tests.", s['bullet']))
    story.append(Paragraph("• <b>Martin, R. C. (2008)</b>. <i>Clean Code: A Handbook of Agile Software Craftsmanship</i>. Prentice Hall. Principes directeurs de lisibilité, de refactoring et de maintenabilité du code source.", s['bullet']))
    story.append(Paragraph("• <b>Gamma, E., Helm, R., Johnson, R., & Vlissides, J. (1994)</b>. <i>Design Patterns: Elements of Reusable Object-Oriented Software</i>. Addison-Wesley. Catalogue fondamental des 23 patrons de conception (GoF).", s['bullet']))

    story.append(Paragraph("2. Documentations techniques et normes officielles", s['h2']))
    story.append(Paragraph("• <b>Documentation Officielle Flutter & Dart</b>. Google LLC. 'Build apps for any screen.' En ligne : https://docs.flutter.dev/ (Consulté en 2026).", s['bullet']))
    story.append(Paragraph("• <b>Documentation Officielle Spring Boot 3</b>. Broadcom / VMware. 'Spring Boot Reference Documentation.' En ligne : https://docs.spring.io/spring-boot/ (Consulté en 2026).", s['bullet']))
    story.append(Paragraph("• <b>Spécification Officielle Jakarta Persistence (JPA)</b>. Eclipse Foundation. 'Jakarta Persistence 3.1.' En ligne : https://jakarta.ee/ (Consulté en 2026).", s['bullet']))
    story.append(Paragraph("• <b>Référence MySQL 8.0 & Sécurité SSL</b>. Oracle Corporation. 'MySQL 8.0 Reference Manual.' En ligne : https://dev.mysql.com/doc/ (Consulté en 2026).", s['bullet']))
    story.append(Paragraph("• <b>Norme ISO/IEC/IEEE 29119</b>. Software and systems engineering — Software testing (Part 1 to Part 5).", s['bullet']))
    story.append(PageBreak())

    # =========================================================================
    # ANNEXES TECHNIQUES
    # =========================================================================
    story.append(Paragraph("ANNEXES TECHNIQUES", s['h1']))
    story.append(HRFlowable(width="100%", thickness=1.5, color=COLOR_PRIMARY, spaceAfter=8))

    story.append(Paragraph("Annexe A : Guide de déploiement continu Cloud (Aiven MySQL & Render)", s['h2']))
    story.append(Paragraph(
        "Cette annexe documente la procédure officielle de déploiement continu du système sur les plateformes cloud managées :",
        s['body']
    ))
    story.append(Paragraph("1. <b>Base de données relationnelle sur Aiven (MySQL 8 Managed)</b> : Création de l'instance avec certificat SSL obligatoire, paramétrage de la chaîne JDBC avec sslMode=REQUIRED, et auto-provisioning des tables via Hibernate.", s['bullet']))
    story.append(Paragraph("2. <b>Backend Spring Boot sur Render (Web Service Docker)</b> : Détection automatique du Dockerfile multi-stage Java 21, injection des variables d'environnement SPRING_DATASOURCE_* et exposition du port dynamique 10000.", s['bullet']))
    story.append(Paragraph("3. <b>Frontend Flutter Web sur Render (Web Service Docker Nginx)</b> : Compilation Flutter en mode release, injection de l'URL cible dans Nginx via docker-entrypoint.sh, proxy_ssl_server_name activé et en-têtes anti-mise en cache.", s['bullet']))

    story.append(Spacer(1, 6))
    story.append(Paragraph("Annexe B : Extraits significatifs du code source Spring Boot", s['h2']))

    t_ab = Table([[
        Paragraph(
            "// Contrôleur REST ReservationMobileController.java (Mise à jour transactionnelle du statut)<br/>"
            "@RestController<br/>"
            "@RequestMapping(\"/api/reservations\")<br/>"
            "@CrossOrigin(origins = \"*\")<br/>"
            "@RequiredArgsConstructor<br/>"
            "public class ReservationMobileController {<br/>"
            "    private final ReservationMobileRepository reservationRepository;<br/>"
            "<br/>"
            "    @PatchMapping(\"/{code}/statut\")<br/>"
            "    public ResponseEntity&lt;?&gt; updateStatut(@PathVariable String code, @RequestBody Map&lt;String, Object&gt; payload) {<br/>"
            "        return reservationRepository.findByCodeReservation(code).map(res -&gt; {<br/>"
            "            if (payload.containsKey(\"statut\")) {<br/>"
            "                res.setStatut(payload.get(\"statut\").toString());<br/>"
            "            }<br/>"
            "            if (payload.containsKey(\"nomGuideValideur\")) {<br/>"
            "                res.setNomGuideValideur(payload.get(\"nomGuideValideur\").toString());<br/>"
            "            }<br/>"
            "            ReservationMobile saved = reservationRepository.save(res);<br/>"
            "            return ResponseEntity.ok(saved);<br/>"
            "        }).orElse(ResponseEntity.notFound().build());<br/>"
            "    }<br/>"
            "}",
            s['code']
        )
    ]], colWidths=[170*mm])
    t_ab.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), COLOR_BG_LIGHT),
        ('BOX', (0,0), (-1,-1), 1, COLOR_PRIMARY),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_ab)

    return story


def generate_exact_pdf(output_pdf_path):
    s = get_styles()
    
    # 1ère passe pour détecter la pagination exacte
    doc_pass1 = SimpleDocTemplate(
        "temp_pass1.pdf",
        pagesize=A4,
        leftMargin=20*mm, rightMargin=20*mm,
        topMargin=20*mm, bottomMargin=20*mm,
    )
    story1 = create_pdf_story(s)
    doc_pass1.build(story1, canvasmaker=AcademicNumberedCanvas)

    # Analyse des pages réelles via pypdf
    reader = pypdf.PdfReader("temp_pass1.pdf")
    page_map = {}
    markers = {
        'dedicaces': 'DÉDICACES',
        'remerciements': 'REMERCIEMENTS',
        'resume': 'RÉSUMÉ TECHNIQUE',
        'glossaire': 'GLOSSAIRE ET LISTE DES SIGLES',
        'sommaire': 'SOMMAIRE GÉNÉRAL',
        'intro': 'INTRODUCTION GÉNÉRALE',
        'chap1': 'CHAPITRE 1 : GESTION DE PROJET',
        'sec12': '1.2 Méthodologie Agile Scrum',
        'sec13': '1.3 Exigences de qualité',
        'sec14': '1.4 Justification des choix',
        'sec15': '1.5 Répartition des rôles',
        'chap2': 'CHAPITRE 2 : SPÉCIFICATION ET ANALYSE',
        'sec22': '2.2 Identification des acteurs',
        'sec23': '2.3 Spécification détaillée',
        'sec24': '2.4 Spécification des besoins non fonctionnels',
        'sec25': '2.5 Modélisation UML',
        'sec26': '2.6 Contraintes opérationnelles',
        'fig21': 'Figure 2.1',
        'fig22': 'Figure 2.2',
        'fig23': 'Figure 2.3',
        'fig24': 'Figure 2.4',
        'chap3': 'CHAPITRE 3 : CONCEPTION DU SYSTÈME',
        'fig31': 'Figure 3.1',
        'sec32': '3.2 Diagramme de composants',
        'fig32': 'Figure 3.2',
        'sec33': '3.3 Diagramme de packages',
        'fig33': 'Figure 3.3',
        'sec34': '3.4 Diagramme de déploiement',
        'fig34': 'Figure 3.4',
        'sec35': '3.5 Diagramme de classes',
        'fig35': 'Figure 3.5',
        'sec36': '3.6 Diagramme d\'objets',
        'fig36': 'Figure 3.6',
        'sec37': '3.7 Design Patterns',
        'chap4': 'CHAPITRE 4 : IMPLÉMENTATION ET TESTS',
        'sec42': '4.2 Développement de la solution',
        'sec43': '4.3 Description approfondie',
        'sec44': '4.4 Gestion des exceptions',
        'sec45': '4.5 Stratégie de tests',
        'conclusion': 'CONCLUSION GÉNÉRALE',
        'biblio': 'BIBLIOGRAPHIE ET WEBOGRAPHIE',
        'annexes': 'ANNEXES TECHNIQUES',
    }

    for idx, page in enumerate(reader.pages):
        text = page.extract_text()
        for key, query in markers.items():
            if key not in page_map and query in text:
                page_map[key] = idx + 1

    # Remplissage par défaut si non trouvé
    for k in markers:
        if k not in page_map:
            page_map[k] = 1

    if os.path.exists("temp_pass1.pdf"):
        os.remove("temp_pass1.pdf")

    # 2ème passe : construction définitive avec la table des matières fidèle
    doc_final = SimpleDocTemplate(
        output_pdf_path,
        pagesize=A4,
        leftMargin=20*mm, rightMargin=20*mm,
        topMargin=20*mm, bottomMargin=20*mm,
    )
    final_story = create_pdf_story(s, page_map)
    doc_final.build(final_story, canvasmaker=AcademicNumberedCanvas)
    print(f"[OK] PDF définitif généré avec succès ({len(pypdf.PdfReader(output_pdf_path).pages)} pages) : {output_pdf_path}")


def generate_matching_docx(output_docx_path):
    doc = docx.Document()
    
    # Marges 2 cm
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)

    # Style titre principal
    p_univ = doc.add_paragraph()
    p_univ.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_u = p_univ.add_run("UNIVERSITÉ ASSANE SECK DE ZIGUINCHOR\n")
    r_u.font.bold = True
    r_u.font.size = Pt(15)
    r_u.font.color.rgb = RGBColor(0x14, 0x5C, 0x42)

    logo_path = 'assets/images/logo_uasz.jpeg'
    if os.path.exists(logo_path):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.add_run().add_picture(logo_path, width=Inches(1.2))

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.add_run("UFR DES SCIENCES ET TECHNOLOGIES\nDépartement Informatique\nLicence en Ingénierie Informatique (Génie Logiciel)\n").font.bold = True

    p_doc = doc.add_paragraph()
    p_doc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_doc = p_doc.add_run("MÉMOIRE DE FIN DE CYCLE — PROJET OPÉRATIONNEL\n")
    r_doc.font.bold = True
    r_doc.font.size = Pt(13)
    r_doc.font.color.rgb = RGBColor(0xC8, 0x75, 0x4D)

    p_theme = doc.add_paragraph()
    p_theme.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_th = p_theme.add_run("« CONCEPTION ET IMPLÉMENTATION D’UNE APPLICATION MOBILE ET WEB DE DÉCOUVERTE ET DE RÉSERVATION DE VISITES TOURISTIQUES ET CULTURELLES EN CASAMANCE »\n")
    r_th.font.bold = True
    r_th.font.size = Pt(13.5)
    r_th.font.color.rgb = RGBColor(0x14, 0x5C, 0x42)

    t_bin = doc.add_table(rows=1, cols=2)
    t_bin.alignment = WD_TABLE_ALIGNMENT.CENTER
    t_bin.rows[0].cells[0].paragraphs[0].add_run(
        "Présenté et soutenu par :\n"
        "• Collé SYLL (Matricule : 202300489)\n"
        "• Ndeye Thiamba FAYE (Matricule : 202300288)"
    ).font.bold = True
    t_bin.rows[0].cells[1].paragraphs[0].add_run(
        "Sous la direction de :\n"
        "• M. Lamine FATY\n"
        "Enseignant-Chercheur\n"
        "Département Informatique, UASZ"
    ).font.bold = True

    doc.add_paragraph("\nMembres du jury :").runs[0].font.bold = True
    t_j = doc.add_table(rows=4, cols=4)
    t_j.style = 'Table Grid'
    headers = ["Prénom et nom", "Grade", "Qualité", "Structure"]
    for i, h in enumerate(headers):
        t_j.rows[0].cells[i].paragraphs[0].add_run(h).font.bold = True
    
    jury_content = [
        ["Dr. ........................................", "Maître de Conférences", "Président", "UASZ"],
        ["M. Lamine FATY", "Enseignant-Chercheur", "Encadrant / Rapporteur", "UASZ"],
        ["Dr. ........................................", "Enseignant-Chercheur", "Examinateur", "UASZ"],
    ]
    for r_idx, row in enumerate(jury_content):
        for c_idx, val in enumerate(row):
            t_j.rows[r_idx+1].cells[c_idx].paragraphs[0].add_run(val)

    p_an = doc.add_paragraph("\nAnnée universitaire : 2025 - 2026")
    p_an.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_an.runs[0].font.bold = True

    doc.add_page_break()

    # Dédicaces & Remerciements
    doc.add_heading("DÉDICACES", level=1)
    doc.add_heading("Dédicace de Collé SYLL :", level=2)
    doc.add_paragraph("Je dédie avec une profonde émotion et une gratitude infinie ce travail à mes très chers parents. Leurs sacrifices inestimables, leur affection sans faille, leurs prières quotidiennes et leurs conseils précieux ont guidé chacun de mes pas tout au long de mes études.")
    doc.add_paragraph("À mes frères, sœurs et proches pour leur bienveillance constante.")
    doc.add_paragraph("À mon binôme Ndeye Thiamba FAYE pour son esprit d'équipe exemplaire, sa rigueur constante et la franche complicité professionnelle qui a rythmé nos journées de développement.")

    doc.add_heading("Dédicace de Ndeye Thiamba FAYE :", level=2)
    doc.add_paragraph("Je dédie ce travail avec toute la tendresse de mon cœur à mes chers parents. Que ce mémoire soit l'humble témoignage de ma reconnaissance éternelle pour leur amour inconditionnel et les sacrifices consentis pour mon éducation et ma réussite.")
    doc.add_paragraph("À l'ensemble de ma famille pour leur soutien moral indéfectible.")
    doc.add_paragraph("À ma binôme Collé SYLL pour son dévouement remarquable et sa persévérance face aux défis d'ingénierie logicielle.")

    doc.add_page_break()
    doc.add_heading("REMERCIEMENTS", level=1)
    doc.add_paragraph("Au terme de ce projet opérationnel de Licence en Ingénierie Informatique, nous rendons grâce à Dieu Tout-Puissant pour la santé, la force et la persévérance accordées.")
    doc.add_paragraph("Nous exprimons notre profonde et sincère gratitude à notre encadrant, Monsieur Lamine FATY, Enseignant-Chercheur au Département Informatique de l'UASZ, pour sa disponibilité, sa rigueur scientifique et son accompagnement bienveillant.")
    doc.add_paragraph("Nos remerciements s'adressent également aux autorités académiques de l'UASZ, à l'UFR Sciences et Technologies, au corps professoral et administratif, aux acteurs touristiques casamançais et à tous nos camarades de promotion.")

    doc.add_page_break()
    doc.add_heading("RÉSUMÉ TECHNIQUE & ABSTRACT", level=1)
    doc.add_paragraph("Ce projet opérationnel porte sur la conception et l'implémentation d'une plateforme logicielle intégrée, multiplateforme (Mobile & Web), dédiée à la découverte géolocalisée et à la réservation de visites touristiques en Casamance. La solution repose sur une architecture 3-tiers découplée associant Flutter (Dart), Spring Boot 3 (Java 21) et MySQL 8 hébergé dans le cloud Aiven avec chiffrement SSL. Le déploiement continu est assuré par Docker sur Render. L'application intègre le calcul de distance de Haversine, un formulaire réactif FormState, des paiements simulés Wave/Orange Money, une billetterie QR Code sécurisée et un espace guide dédié avec validation instantanée.")
    doc.add_paragraph("Mots-clés : Génie Logiciel, Flutter, Spring Boot 3, MySQL 8, Architecture 3-Tiers, Résilience Hors-Ligne, Billetterie QR Code, Formule de Haversine, Cloud Render & Aiven, UASZ.")

    doc.add_heading("TECHNICAL ABSTRACT", level=2)
    doc.add_paragraph("This capstone project focuses on the engineering and implementation of an integrated cross-platform mobile and web application dedicated to the digital discovery and booking of cultural tours in Casamance. The system implements a modern 3-Tier architecture: Flutter/Dart for responsive UI and offline resilience (SharedPreferences), Spring Boot 3 and Java 21 for stateless RESTful APIs, and an Aiven-managed MySQL 8 cloud database over enforced SSL tunnels. Delivered features comprise an interactive catalog with Haversine distance calculations, a robust booking engine, mobile money workflows, dynamic tamper-proof QR code tickets, and a dedicated Tour Guide Dashboard.")
    doc.add_paragraph("Keywords : Software Engineering, Flutter, Spring Boot, RESTful API, Offline-First Architecture, QR Code Ticketing, Mobile Money, Cultural Heritage, Casamance.")

    doc.add_page_break()
    doc.add_heading("INTRODUCTION GÉNÉRALE", level=1)
    doc.add_paragraph("1. Contexte du projet : La région naturelle de Casamance dispose d'un patrimoine d'une richesse exceptionnelle. Toutefois, l'enclavement, l'absence de canaux numériques centralisés et la dépendance aux espèces créent des frictions. L'adoption massive de la téléphonie mobile et de Wave / Orange Money ouvre une opportunité stratégique.")
    doc.add_paragraph("2. Problématique technique de Génie Logiciel : Comment concevoir et implémenter une architecture logicielle distribuée (Mobile et Web), découplée et sécurisée, capable d'assurer la continuité absolue de service en mode déconnecté (Offline-First), de garantir l'infalsifiabilité des billets numériques par encodage QR cryptographique et de réconcilier de manière fiable les flux financiers électroniques et physiques pour la valorisation du patrimoine touristique de la Casamance ?")
    doc.add_paragraph("3. Objectifs du rapport : Spécifier, modéliser avec UML, concevoir en 3-tiers découplé avec patrons de conception (Singleton, DTO, Repository, IoC), implémenter avec typage fort (Dart 3 / Java 21) et valider par des tests automatisés.")
    doc.add_paragraph("4. Annonce du plan : Chapitre 1 (Gestion de projet et méthodologie), Chapitre 2 (Cahier des charges et spécifications), Chapitre 3 (Conception logicielle 3-tiers), Chapitre 4 (Implémentation et tests), suivi de la Conclusion, Bibliographie et Annexes.")

    doc.add_page_break()
    doc.add_heading("CHAPITRE 1 : GESTION DE PROJET ET APPROCHE MÉTHODOLOGIQUE", level=1)
    doc.add_paragraph("1.1 Contexte technique en Génie Logiciel : Exigences d'hétérogénéité des terminaux, tolérance aux pannes réseau et intégrité transactionnelle.")
    doc.add_paragraph("1.2 Méthodologie Agile Scrum : 7 sprints incrémentaux, rituels Scrum (Daily standup, sprint planning, review).")
    doc.add_paragraph("1.3 Qualité logicielle et métriques : Norme ISO/IEC 25010, règle du Boy Scout, typage strict sound null safety, 0 issue sur flutter analyze.")
    doc.add_paragraph("1.4 Justification des choix : Flutter vs React Native, Spring Boot 3 vs Node/Django, MySQL 8 vs MongoDB, Docker/Render/Aiven.")
    doc.add_paragraph("1.5 Répartition des rôles (Matrice RACI) : Collé SYLL (Direction architecturale, Backend Spring Boot, API REST, MySQL, Docker/Render/Aiven) et Ndeye Thiamba FAYE (UI/UX Mobile, Réservation FormState, Billetterie QR, Favoris hors-ligne, Espace Guide).")

    doc.add_page_break()
    doc.add_heading("CHAPITRE 2 : SPÉCIFICATION ET ANALYSE DES BESOINS (CAHIER DES CHARGES)", level=1)
    doc.add_paragraph("2.1 Recueil des besoins : Enquêtes terrain auprès des guides accrédités, touristes et gestionnaires.")
    doc.add_paragraph("2.2 Acteurs et User Stories : Touriste, Guide Touristique, Administrateur. 8 User Stories formalisées en syntaxe Gherkin (US-01 à US-08).")
    doc.add_paragraph("2.3 Spécification des besoins fonctionnels : F1 (Catalogue & Haversine), F2 (Favoris hors-ligne), F3 (Réservation & FormState), F4 (Paiement hybride Wave/OM/Guichet), F5 (Billet QR Code infalsifiable), F6 (Espace Guide et audit caisse).")
    doc.add_paragraph("2.4 Spécification des besoins non fonctionnels : Usabilité Material 3 (WCAG AA), résilience offline-first, sécurité SSL/BCrypt, temps de réponse < 200 ms.")
    doc.add_paragraph("2.5 Modélisation UML : Diagramme de cas d'utilisation, diagrammes de séquence système (réservation, scan guide), diagramme d'états-transitions.")
    doc.add_paragraph("2.6 Contraintes opérationnelles : Anti-rejeu strict, performance à froid < 2s, portabilité native Android et Web.")

    doc.add_page_break()
    doc.add_heading("CHAPITRE 3 : CONCEPTION DU SYSTÈME (GÉNIE LOGICIEL)", level=1)
    doc.add_paragraph("3.1 Architecture globale 3-Tiers : Couche Présentation (Flutter), Couche Métier (Spring Boot 3), Couche Données (MySQL 8 Aiven SSL).")
    doc.add_paragraph("3.2 Diagramme de composants : Découplage fonctionnel UI, Services, Cache local, Contrôleurs REST, DAO.")
    doc.add_paragraph("3.3 Diagramme de packages : Organisation modulaire claire (lib/core, lib/features_colle, lib/features_thiamba et packages Java backend).")
    doc.add_paragraph("3.4 Diagramme de déploiement Cloud : Reverse-proxy Nginx avec proxy_ssl_server_name sur Render, microservice Docker Java 21, cluster MySQL managé Aiven.")
    doc.add_paragraph("3.5 Diagramme de classes métier : Entités relationnelles Patrimoine, ReservationMobile, CompteMobile, AvisMobile, UtilisateurBdd.")
    doc.add_paragraph("3.6 Diagramme d'objets : Instanciation réelle lors de la validation d'un billet à l'Île de Carabane.")
    doc.add_paragraph("3.7 Design Patterns appliqués : Singleton, Observer/Reactive State, DTO, Repository, Dependency Injection (IoC), Factory Method.")

    doc.add_page_break()
    doc.add_heading("CHAPITRE 4 : IMPLÉMENTATION ET TESTS FONCTIONNELS", level=1)
    doc.add_paragraph("4.1 Environnement technique : Flutter 3.47, Dart 3.13, Spring Boot 3.2.5, Java 21 OpenJDK, MySQL 8, Docker Engine, Nginx Alpine.")
    doc.add_paragraph("4.2 Modules applicatifs développés : Catalogue immersif, formulaire avec FormState, billet QR haute densité, Espace Guide déverrouillé par PIN 2026.")
    doc.add_paragraph("4.3 Algorithmes clés : Calcul géodésique de Haversine, encodage et signature du payload QR Code, décodage et contrôle anti-rejeu.")
    doc.add_paragraph("4.4 Gestion des exceptions et résilience réseau : Try/catch typés interceptant SocketException/TimeoutException avec bascule instantanée sur SharedPreferences.")
    doc.add_paragraph("4.5 Stratégie de tests : Grille de 10 tests fonctionnels et d'intégration couvrant tous les flux, validés avec 100 % de succès.")

    doc.add_page_break()
    doc.add_heading("CONCLUSION GÉNÉRALE ET PERSPECTIVES", level=1)
    doc.add_paragraph("1. Bilan : Objectifs intégralement atteints avec une application en production sur le cloud, résiliente et sécurisée.")
    doc.add_paragraph("2. Difficultés surmontées : Synchronisation hors-ligne, portabilité responsive multi-écrans, déploiement Docker SSL SNI.")
    doc.add_paragraph("3. Perspectives : Passerelles marchandes réelles Wave/OM, audioguide multilingue (Diola/Wolof/FR/EN), moteur de recommandation IA.")

    doc.add_page_break()
    doc.add_heading("BIBLIOGRAPHIE ET ANNEXES", level=1)
    doc.add_paragraph("Sommerville (2016), Pressman (2020), Clean Code Martin (2008), GoF Design Patterns (1994). Documentations officielles Flutter, Spring Boot, MySQL. Norme ISO/IEC/IEEE 29119.")
    doc.add_paragraph("Annexe A : Guide de déploiement continu Cloud (Render & Aiven). Annexe B : Extraits de code source de ReservationMobileController.java.")

    doc.save(output_docx_path)
    print(f"[OK] Fichier Word DOCX généré avec succès : {output_docx_path}")


if __name__ == '__main__':
    out_pdf = 'Memoire_L3_Informatique_UASZ_Syll_Faye.pdf'
    out_docx = 'Memoire_L3_Informatique_UASZ_Syll_Faye.docx'
    generate_exact_pdf(out_pdf)
    generate_matching_docx(out_docx)
