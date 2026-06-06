from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from .models import Note

class NoteModelTest(TestCase):
    def setUp(self):
        # This runs before every test to set up dummy data
        self.note = Note.objects.create(title="DevOps Test Note", content="Testing the model")

    def test_note_str(self):
        """Test the string representation of the model"""
        self.assertEqual(str(self.note), "DevOps Test Note")


class NoteAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.note = Note.objects.create(title="API Test", content="API Content")
        self.valid_payload = {
            "title": "Automated Note",
            "content": "Created by unit test"
        }

    def test_get_all_notes(self):
        """Test that the API successfully returns a list of notes"""
        response = self.client.get('/api/notes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # We created 1 note in setUp, so the API should return exactly 1 note
        self.assertEqual(len(response.data), 1)

    def test_create_valid_note(self):
        """Test that sending a POST request creates a new note in the database"""
        response = self.client.post('/api/notes/', data=self.valid_payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # We started with 1 note, now we should have 2
        self.assertEqual(Note.objects.count(), 2)
        # Check if the title matches what we sent
        self.assertEqual(Note.objects.latest('id').title, "Automated Note")