from rest_framework import serializers
from .models import *
class IngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ingredient
        fields = ['id', 'name']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']

class NutritionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Nutrition
        fields = ['id', 'calories', 'protein', 'fat', 'carbs']
        
class UserSerializer(serializers.ModelSerializer):
    avatar = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "email", "username", "avatar", "created_at"]

    def get_avatar(self, obj):
        request = self.context.get("request")
        if obj.avatar and request:
            return request.build_absolute_uri(obj.avatar.url)
        return None


class RecipeSerializer(serializers.ModelSerializer):
    ingredients = IngredientSerializer(many=True, read_only=True)
    category = CategorySerializer(read_only=True)
    created_by = UserSerializer(read_only=True)
    nutrition = NutritionSerializer(read_only=True) 
    # steps = CookingStepSerializer(many=True, read_only=True)
    nutrition = NutritionSerializer(read_only=True) # хэрэв Nutrition нь OneToOneField байвал

    class Meta:
        model = Recipe
        fields = [
            'id',
            'name',
            'description',
            'image',
            'time_required',
            'servings',
            'cuisine',
            'category',
            'ingredients',
            'nutrition',
            'created_by',
            'created_at'
        ]

class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    avatar = serializers.ImageField(required=False)

    class Meta:
        model = User
        fields = ("id", "email", "username", "password", "avatar")

    def create(self, validated_data):
        password = validated_data.pop("password")
        avatar = validated_data.pop("avatar", None)

        user = User.objects.create_user(
            email=validated_data["email"],
            username=validated_data["username"],
            password=password,
        )

        if avatar:
            user.avatar = avatar
            user.save()

        return user
    
class UserUpdateSerializer(serializers.ModelSerializer):
    avatar = serializers.ImageField(required=False)
    remove_avatar = serializers.BooleanField(write_only=True, required=False, default=False)

    class Meta:
        model = User
        fields = ("email", "username", "avatar", "remove_avatar")

    def update(self, instance, validated_data):
        # avatar устгах
        if validated_data.pop("remove_avatar", False):
            if instance.avatar:
                instance.avatar.delete(save=False)
            instance.avatar = None

        # avatar солих
        new_avatar = validated_data.pop("avatar", None)
        if new_avatar:
            if instance.avatar:
                instance.avatar.delete(save=False)
            instance.avatar = new_avatar

        # бусад талбар
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.save()
        return instance
   


class WishlistSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    recipe = RecipeSerializer(read_only=True)
    class Meta:
        model = Wishlist
        fields = "__all__"

