from django.db import models

# 🔹 Хэрэглэгчийн энгийн table
class User(models.Model):
    username = models.CharField(max_length=50, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # hashed password хадгалах боломжтой
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username

# 🔹 Категори
class Category(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='category_images/', blank=True, null=True)

    def __str__(self):
        return self.name

# 🔹 Орц
class Ingredient(models.Model):
    name = models.CharField(max_length=50, unique=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='ingredients')

    def __str__(self):
        return self.name

# 🔹 Жор
class Recipe(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='recipe_images/')
    time_required = models.CharField(max_length=50)
    servings = models.PositiveIntegerField()
    cuisine = models.CharField(max_length=50, blank=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='recipes')
    ingredients = models.ManyToManyField(Ingredient, related_name='recipes')
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='recipes')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

# 🔹 Алхам алхмаар хийх
class CookingStep(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name='steps')
    step_number = models.PositiveIntegerField()
    description = models.TextField()

    class Meta:
        ordering = ['step_number']

    def __str__(self):
        return f"{self.recipe.name} - Step {self.step_number}"

# 🔹 Илчлэг
class Nutrition(models.Model):
    recipe = models.OneToOneField(Recipe, on_delete=models.CASCADE, related_name='nutrition')
    calories = models.CharField(max_length=50, blank=True)
    protein = models.CharField(max_length=50, blank=True)
    fat = models.CharField(max_length=50, blank=True)
    carbs = models.CharField(max_length=50, blank=True)

    def __str__(self):
        return f"{self.recipe.name} Nutrition"
